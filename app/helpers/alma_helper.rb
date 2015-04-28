module AlmaHelper
	def openurl
		"https://#{ENV['alma']}.alma.exlibrisgroup.com/view/uresolver/#{ENV['institution']}/openurl?"
	end
end
