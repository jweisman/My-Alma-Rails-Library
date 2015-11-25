class Deposit
	include S3Helper
	include ActiveModel::Model
	include ActiveModel::Validations

	validate { errors.add(:metadata, 'Title is mandatory') unless metadata.has_key?(:title) && !metadata[:title].empty? }
	validates :import_profile, presence: true

	attr_accessor :import_profile, :metadata, :folder_name

	def new_record? 
		return self.metadata.length==0
	end

	def initialize(attributes={})
		super
		self.metadata ||= Hash.new
		self.folder_name ||= SecureRandom.uuid.gsub(/-/,'')
	end

	def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def to_json
  	{ metadata: self.metadata, 
  		folder_name: self.folder_name, 
  		import_profile: self.import_profile
  	}.to_json  
	end

  def filestreams
    @filestreams ||= get_files(folder)
      .contents.reject{ |f| f.key.ends_with? ".lock" }.
      map{ |f|
        Filestream.new({ key: f.key, file_size: f.size}) 
      }
  end  

  def folder
    ENV['institution'] + "/upload/#{import_profile}/#{folder_name}"
  end  

  def delete_filestreams
  	filestreams.each{ |f| 
  		delete_file f.key
  	}
  	unlock
  end

  def save_metadata_file
  	write_file "#{folder}/marc.xml", marc
  end

	def lock
		write_file "#{folder}/.lock", nil 
		#folder
	end

  def unlock
  	delete_file "#{folder}/.lock"
  end

  def marc
      %Q(
        <collection>
           <record>
              <leader>     aas          a     </leader>
              <controlfield tag="008">       #{Time.now.strftime("%Y")}</controlfield>
              <datafield tag="100" ind1="1" ind2=" ">
                <subfield code="a">#{metadata[:author]}</subfield>
              </datafield>
              <datafield tag="245" ind1="1" ind2="2">
                <subfield code="a">#{metadata[:title]}</subfield>
              </datafield>
              <datafield tag="260" ind1=" " ind2=" ">
                <subfield code="c">#{Time.now.strftime("%B %d, %Y")}</subfield>
              </datafield>
           </record>
         </collection> 
      )
  end  

end