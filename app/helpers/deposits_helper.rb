require 'base64'

module DepositsHelper
	def formatFileSize(bytes) 
	    return '' if !bytes.is_a? Numeric
	    return '%.02f GB' % (bytes / 1000000000) if bytes >= 1000000000
	    return '%.02f MB' % (bytes / 1000000) if bytes >= 1000000
	    return '%.02f KB' % (bytes / 1000)
    end
	
	def collection_name(import_profile)
		import_profile["digital_details"]["collection_assignment"]["desc"]
	end

	def decode(url)
		URI.unescape(url)
	end

  def base64_encode(bin, padding: false)
  	str = Base64.strict_encode64(bin).tr("+/", "-_")
  	str = str.delete("=") unless padding
  	str
  end

end
