module DepositsHelper
	def formatFileSize(bytes) 
	    return '' if !bytes.is_a? Numeric
	    return '%.02f GB' % (bytes / 1000000000) if bytes >= 1000000000
	    return '%.02f MB' % (bytes / 1000000) if bytes >= 1000000
	    return '%.02f KB' % (bytes / 1000)
    end
end
