require 'sword2ruby'

module SwordHelper
	def sword_sd
		service = Atom::Service.new("#{sword_service}/sd", sword_connection)
		service.collections
	end	

	def sword_zip_deposit(collection, dc, draft, zip_file)
		#Create entry
		entry = Atom::Entry.new
		dc.each do |param|
			param[1].each do |val|
				entry.add_dublin_core_extension! param[0], val
			end
		end

		collection = Atom::Collection.new( collection )

		#Post to the collection
		deposit_receipt = collection.post_multipart!(
			:connection=>sword_connection,
			:entry=>entry,
			:filepath=>zip_file.to_s, 
			:content_type=>"application/zip", 
			:in_progress=>draft,
			:packaging=>"http://purl.org/net/sword/package/SimpleZip"
			)
	end

	def sword_get_deposit(id)
		Sword2Ruby::DepositReceipt.new(
   		sword_connection.get(
   			"#{sword_service}/edit/#{id}"), 
   		sword_connection)
	end

	def sword_update_md(id, dc, in_progress = true)
		deposit = sword_get_deposit(id)
		entry = deposit.entry

		dc.each do |param|
			entry.delete_dublin_core_extension! param[0]
			param[1].each do |val|
				entry.add_dublin_core_extension! param[0], val
			end
		end
   	
   	entry.put!( { in_progress: in_progress } )
	end

	def sword_delete_deposit(id)
		deposit = sword_get_deposit(id)
		entry = deposit.entry
		entry.delete!
	end

	def sword_add_zip(id, zip_file)
		deposit = sword_get_deposit(id)
		entry = deposit.entry

		entry.post_media!(
			:filepath=>zip_file.to_s, 
			:content_type=>"application/zip", 
			:packaging=>"http://purl.org/net/sword/package/SimpleZip"
		)
	end

	def sword_delete_file(uri)
		sword_connection.delete uri
	end

  def dc_fields
    [REXML::Element.new('creator'), REXML::Element.new('title')]
  end

  def sword_service
  	"https://#{ENV["alma"]}.alma.exlibrisgroup.com/sword/#{ENV["institution"]}"
  end

	private

	def sword_connection
		@sword_user ||= Sword2Ruby::User.new(
			ENV['sword_user'],
			ENV['sword_pass'],
			@obo
			)
		@sword_connection ||=
			Sword2Ruby::Connection.new(@sword_user)
	end

end
