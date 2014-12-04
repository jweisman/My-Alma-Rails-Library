class Deposit < ActiveRecord::Base
	belongs_to :user
	has_many :source_files
	serialize :metadata, JSON
	after_initialize :init

	def init
		self.metadata ||= Hash.new
	end
end