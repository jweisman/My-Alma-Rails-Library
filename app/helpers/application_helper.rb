module ApplicationHelper
	include AlmaHelper

	def paging_html(hits, start_param = 'start', page_size = 10)
                
        start = (params[start_param] || 0).to_i
        number_of_buttons = 5
        paging = ""
        
        # calculate current page
        current_page = (start/page_size)
        if hits > page_size*5 # more than 5 pages - show middle number_of_buttons
                if current_page < number_of_buttons - 1
                        min_page = 0
                        max_page = number_of_buttons - 1
                        ellipsis = 'end'
                elsif current_page >= (hits/page_size).ceil - (number_of_buttons-1)/2
                        min_page = (hits/page_size).ceil - number_of_buttons + 1
                        max_page = (hits/page_size).ceil
                        ellipsis = 'begin'
                else
                        min_page = current_page - (number_of_buttons-1)/2
                        max_page = current_page + (number_of_buttons-1)/2
                        ellipsis = 'both'
                end
        elsif hits.between?(page_size*2, page_size*5) # less than 5 pages- show all
                min_page = 0
                max_page = (hits / page_size) - ((hits % page_size == 0) ? 1 : 0)
        else
                min_page = 0
                max_page = -1
        end
       
        paging << '<div class="col-md-8" id="paging">'
        if hits > page_size             
            paging << %Q[
                <p><strong>Showing #{start + 1} to #{hits <= start + page_size ? hits : start + page_size} of #{hits} results</strong></p>
            ]

            paging << %Q[
            <div class="btn-toolbar" role="toolbar" aria-label="...">
            <div class="btn-group" role="group" aria-label="...">
                <a href="#{url_for(params.merge(start_param => start - page_size))}" class="btn btn-default#{start == 0 ? ' disabled' : ''} paging-link">&lt;&lt; Previous</a>
            </div>
            <div class="btn-group" role="group" aria-label="...">
            ]
            paging << "<a class='btn btn-default disabled'> ... </a>" if %w[begin both].include?(ellipsis)
            for i in min_page..max_page
                paging << %Q[
                    <a href="#{url_for(params.merge(start_param => page_size*i))}" class="btn btn-#{i == current_page ? 'primary' : 'default'} paging-link">#{i+1}</a>
                ]
            end
            paging << "<a class='btn btn-default disabled'> ... </a>" if %w[end both].include?(ellipsis)
            paging << %Q[
            </div>
            <div class="btn-group" role="group" aria-label="...">
                <a href="#{url_for(params.merge(start_param => start + page_size))}" class="btn btn-default#{hits <= start + page_size ? ' disabled' : ''} paging-link">Next &gt;&gt;></a>
            </div>
            </div>
        	]
        end
        paging << '</div>'
        paging.html_safe
	end
end
