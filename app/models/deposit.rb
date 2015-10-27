include S3Helper

class Deposit 
	include ActiveModel::Model
	include ActiveModel::Validations
  	include ActiveModel::Serialization

	validates :import_profile, presence: true
	#belongs_to :user
	#has_many :filestreams
	#serialize :metadata, JSON
	#after_initialize :init

	#before_destroy {
		# cascading delete not working
    #	self.filestreams.each { |f| f.destroy }
    #	delete_file "#{ENV['institution']}/upload/#{self.import_profile}/#{self.folder_name}/.lock"
	#}

	def init
		self.metadata ||= Hash.new
	    self.status ||= "CREATED"
	    self.folder_name ||= SecureRandom.uuid.gsub(/-/,'')
	end

end