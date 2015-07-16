class CatalogController < ApplicationController

  include AwsHelper

  def show
    if params[:q]
      @results = cs_search(params[:q], params[:start] || 0)
    end
  end

  def availability
    bib = alma_get_bib_availability(params[:mms_id])
    render json: bib
  end

  def admin
    render :login and return unless admin_user?
    respond_to do |format|
      format.html
      format.json { render json: catalog_stats }
    end
  end

  def harvest

    set_streaming_headers
    self.response_body = Enumerator.new do |y|
      y << "Retrieving 'from' time" + "\n"
      from_time = params[:reindex] ? '' : oai_from_time_qs
      y << from_time + "\n"
       
      # set to date
      to_time = Time.new.getutc.strftime("%Y-%m-%dT%H:%M:%SZ")
      y << "Set 'to' time to: #{to_time}" + "\n"
       
      qs = "?verb=ListRecords&set=#{ENV['oaiset']}&metadataPrefix=marc21&until=#{to_time}#{from_time}"
      oai_base = "https://#{ENV['alma']}.alma.exlibrisgroup.com/view/oai/#{ENV['institution']}/request"

      begin 
        #resumptionToken = process_oai(inst, qs, domain, alma_inst)
        y << "Calling OAI with query string #{qs}" + "\n"
        oai = RestClient.get oai_base + qs

        document = Nokogiri::XML(oai)
        xsl = RestClient.get 'https://gist.githubusercontent.com/jweisman/1ae658243a0bad01f91e/raw/oai-to-aws-cloudsearch.xsl'
        template = Nokogiri::XSLT(xsl)

        recordCount = document.xpath('/oai:OAI-PMH/oai:ListRecords/oai:record', {'oai' => 'http://www.openarchives.org/OAI/2.0/'}).count
        y << "#{recordCount} records retrieved" + "\n"

        if recordCount > 0
          csPayload = template.transform(document).to_s.strip #remove trailing spaces...
          response = cs_post(csPayload)
          y << "Sent to CloudSearch: #{response.gsub(/\n/, ' ')}" + "\n"
        end
        
        resumptionToken = document.xpath('/oai:OAI-PMH/oai:ListRecords/oai:resumptionToken', {'oai' => 'http://www.openarchives.org/OAI/2.0/'}).text

        qs = '?verb=ListRecords&resumptionToken=' + resumptionToken
      end until resumptionToken == ''
       
      # write to date for next time
      y << "Storing 'to' time" + "\n"
      s3_write_file ENV['amazonscratchbucket'], 'oai-discovery-from-time.txt', to_time
       
      y << "Complete" + "\n"

    end
    response.stream.close
  end

  private

  def set_streaming_headers
    #nginx doc: Setting this to "no" will allow unbuffered responses suitable for Comet and HTTP streaming applications
    headers['X-Accel-Buffering'] = 'no'

    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")
  end  

  def oai_from_time_qs
    from_time = oai_from_time
    if from_time != ''
      return "&from=#{from_time}"
    else
      return ''
    end
  end

  def oai_from_time
    from_time = ''
    # retrieve from date
    RestClient.get("https://#{ENV['amazonscratchbucket']}.s3.amazonaws.com/oai-discovery-from-time.txt") {
    |response, request, result| 
      if response.code == 200
        from_time = response
        #log "Retrieved from time: #{from_time}"
      end
    }    
    return from_time
  end

  def catalog_stats
    { cs_record_count: cs_record_count,
        last_harvest: oai_from_time
    }
  end


end
