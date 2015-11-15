class CollectionsController < ApplicationController

	def index
		@collections = alma_api_get "/bibs/collections"
	end
	
	def show
		@collection = alma_api_get "/bibs/collections/#{params[:id]}?level=2"
		@titles = get_titles params[:id]
	end

	def titles
		respond_to do |format|
				format.html {
					@titles = get_titles params[:collection_id]
					render layout: false
				}
				format.json {
					render json: get_files(params[:id])['representation_file'].map{|f| 
						{src: f['url'], subHtml: "<h4>#{f['label']}</h4>"}
					}
				}
			end
	end

	private

	def get_files(mms_id)
		reps = alma_api_get "/bibs/#{mms_id}/representations"
		files = alma_api_get "/bibs/#{mms_id}/representations/#{reps['representation'][0]['id']}/files?expand=url"
	end

	def get_titles(collection_id)
		start = params["start"] || 0
		@limit = params["limit"] || 6
		alma_api_get "/bibs/collections/#{collection_id}/bibs?offset=#{start}&limit=#{@limit}"
	end

end