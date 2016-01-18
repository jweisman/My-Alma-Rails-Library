require 'zip'
require 'base64'

module Utilities

	def zip_files(path, files)
		Zip::File.open(path, Zip::File::CREATE) do |zipfile|
	  		files.each do |file|
	  			zipfile.add(file.original_filename, file.path)
	  		end
	  	end
  	end

  def base64_decode(str)
	  # NOTE: RFC 4648 does say nothing about unpadded input, but says that
	  # "the excess pad characters MAY also be ignored", so it is inferred that
	  # unpadded input is also acceptable.
	  str = str.tr("-_", "+/")
	  if !str.end_with?("=") && str.length % 4 != 0
	    str = str.ljust((str.length + 3) & ~3, "=")
	  end
	  Base64.strict_decode64(str)
  end
end