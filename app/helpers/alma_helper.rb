module AlmaHelper
	def openurl
		"https://#{ENV['alma']}.alma.exlibrisgroup.com/view/uresolver/#{ENV['institution']}/openurl?" +
		 	(current_user && current_user.provider=='saml' ? "sso=true&token=#{session.id}&" : "") 
	end
end
