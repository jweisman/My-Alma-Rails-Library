module ApplicationHelper
	include AlmaHelper

	def paging_html(hits, start_param)
		# TODO: add handling for intermediate buttons
        if hits > 10 
            start = (params[start_param] || 0).to_i
        %Q[<p><strong>Showing #{start + 1} to #{hits <= start + 10 ? hits : start + 10} of #{hits}</strong></p>
        <div class="btn-group" role="group" aria-label="...">
            <a href="#{url_for(params.merge(start_param => start - 10))}" class="btn btn-default#{start == 0 ? ' disabled' : ''}">&lt;&lt; Previous</a>
            <a href="#{url_for(params.merge(start_param => start + 10))}" class="btn btn-default#{hits <= start + 10 ? ' disabled' : ''}">Next &gt;&gt;></a>
        </div>
    	].html_safe
        end
	end
end
