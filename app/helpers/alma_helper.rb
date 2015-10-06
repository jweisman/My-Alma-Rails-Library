module AlmaHelper
	def openurl
		"https://#{ENV['alma']}.alma.exlibrisgroup.com/view/uresolver/#{ENV['institution']}/openurl?rfr_id=info:sid/primo.exlibrisgroup.com&u.ignore_date_coverage=true&" +
		 	(current_user && current_user.provider=='saml' ? "sso=true&token=#{session.id}&" : "") 
	end

	def thumburl(id)
		"https://#{ENV["alma"]}.alma.exlibrisgroup.com/view/delivery/thumbnail/#{ENV['institution']}/#{id}"
	end
end
