require 'zip'

module Utilities

	def zip_files(path, files)
		Zip::File.open(path, Zip::File::CREATE) do |zipfile|
	  		files.each do |file|
	  			zipfile.add(file.original_filename, file.path)
	  		end
	  	end
  	end

end