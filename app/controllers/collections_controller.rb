class CollectionsController < ApplicationController

	def index
		@collections = alma_api_get "/bibs/collections"
	end
	
	def show
		@collection = alma_api_get "/bibs/collections/#{params[:id]}?level=2"
		@titles = get_titles
	end

	def titles
		@titles = get_titles
		render layout: false
	end

	private

	def get_titles
		start = params["start"] || 0
		@limit = params["limit"] || 6
		alma_api_get "/bibs/collections/#{params[:id]}/bibs?offset=#{start}&limit=#{@limit}"
	end

end