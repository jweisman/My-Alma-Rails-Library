require 'sword2ruby'

module SwordHelper
	def sword_sd
		service = Atom::Service.new("#{ENV["sword_service"]}/sd", sword_connection)
		service.collections
	end	

	def sword_zip_deposit(collection, dc, zip_file)
		#Create entry
		entry = Atom::Entry.new
		dc.each do |param|
			entry.add_dublin_core_extension! param[0], param[1]
		end

		collection = Atom::Collection.new( collection )

		#Post to the collection
		deposit_receipt = collection.post_multipart!(
			:connection=>sword_connection,
			:entry=>entry,
			:filepath=>zip_file.to_s, 
			:content_type=>"application/zip", 
			:packaging=>"http://purl.org/net/sword/package/SimpleZip"
			)
	end

	def sword_get_deposit(id)
		Sword2Ruby::DepositReceipt.new(
   		sword_connection.get(
   			"#{ENV["sword_service"]}/edit/#{id}"), 
   		sword_connection)
	end

	def sword_update_md(id, dc)
		deposit = sword_get_deposit(id)
		entry = deposit.entry

		dc.each do |param|
			entry.delete_dublin_core_extension! param[0]
			entry.add_dublin_core_extension! param[0], param[1]
		end
   	
   	entry.put!
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

  def dc_fields
    [REXML::Element.new('creator'), REXML::Element.new('title')]
  end

	private

	def sword_connection
		@sword_user ||= Sword2Ruby::User.new(
			'apikey', 
			ENV["apikey"], 
			@obo
			)
		@sword_connection ||=
			Sword2Ruby::Connection.new(@sword_user)
	end

end
