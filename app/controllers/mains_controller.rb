require "open-uri"

class MainsController < ApplicationController


	def new
		render '/mains/new'
	end
	def create		

		@search_key = params[:search_key]		
			item_plus = params[:search_key]
			item_underscore = params[:search_key]
			i = 0
			for i in 0..item_plus.length
				if item_plus[i] == " "
					item_underscore[i] = "_"
					item_plus[i] = "+"
				end
				i = i + 1
			end

			# AMAZON
		url = "http://www.amazon.com/s/ref=nb_sb_noss_1?url=search-alias%3Daps&field-keywords=#{item_plus}"
		amazon_dump = Array.new
		amazon_price = Array.new
		amazon_image = Array.new
		amazon_link = Array.new


		amazon_page = Nokogiri::HTML(open(url))
		amazon_search_result = amazon_page.css('.s-result-item')

		amazon_search_result.each do |item|		
			amazon_link.push(item.css('.a-row.a-spacing-none a').map {|a| a['href']})
				if amazon_image.length < 5
					amazon_image.push(item.css('a.a-link-normal.a-text-normal img').map { |img| img['src'] })
				end
				if amazon_dump.length < 5
					amazon_dump.push(item.css(".a-size-medium.s-inline.s-access-title.a-text-normal").text)
				end
				if item.css('.a-size-base.a-color-price.s-price.a-text-bold').nil?
					amazon_dump.pop()
				else
					if amazon_price.length < 5
						amazon_price.push(item.css('.a-size-base.a-color-price.s-price.a-text-bold').text)
					end
				end
			end
		@amazon = amazon_dump.zip(amazon_price,	amazon_image,amazon_link)

		# CRAIGSLIST
		url = "http://seattle.craigslist.org/search/sss?query=#{item_underscore}&sort=rel"
		craigslist_dump = Array.new
		craigslist_price = Array.new
		craigslist_image = Array.new
		craigslist_link = Array.new

		craigslist_page = Nokogiri::HTML(open(url))
		craigslist_search_result = craigslist_page.css(".row")
		craigslist_search_result.each do |item|
			if craigslist_dump.length < 5
				craigslist_dump.push(item.at_css('.hdrlnk').text.strip)
			end
			if item.at_css('.l2 .price').nil?
				craigslist_dump.pop()
			else
				if craigslist_price.length < 5
		  			craigslist_price.push(item.at_css('.l2 .price').text.strip)
		  		end
			end
		  
		end

		@craigslist = craigslist_dump.zip(craigslist_price)

		# WALMART
		url = "http://www.walmart.com/search/search-ng.do?search_constraint=0&ic=48_0&search_query=#{item_underscore}&Find.x=0&Find.y=0&Find=Find"
		walmart_dump = Array.new
		walmart_price = Array.new
		walmart_image = Array.new
		walmart_link = Array.new

		walmart_page = Nokogiri::HTML(open(url))
		walmart_page.css(".js-tile.tile-landscape").each do |item|
			if walmart_image.length < 5
				walmart_image.push(item.css('.js-product-image img').map { |img| img['data-default-image'] })
			end
			if walmart_dump.length < 5
			walmart_dump.push(item.at_css('.js-product-title').text)
			end	
			if item.at_css('.price-display').nil?
				walmart_dump.pop()
			else
				if walmart_price.length < 5
		  		walmart_price.push(item.at_css('.price-display').text)
		  		end
		  	end
		end
		
		@walmart = walmart_dump.zip(walmart_price,walmart_image, walmart_link)

		# BESTBUY
		url = "http://www.bestbuy.com/site/searchpage.jsp?st=#{item_plus}&_dyncharset=UTF-8&id=pcat17071&type=page&sc=Global&cp=1&nrp=15&sp=&qp=&list=n&iht=y&usc=All+Categories&ks=960&keys=keys"
		bestbuy_dump = Array.new
		bestbuy_price = Array.new
		bestbuy_image = Array.new
		bestbuy_link = Array.new

		bestbuy_page = Nokogiri::HTML(open(url))
		bestbuy_page.css(".list-item-info").each do |item|
			# if bestbuy_dump.length < 5
				bestbuy_dump.push(item.at_css('.sku-title').text)
			# end
			if item.at_css('.medium-item-price').nil?
				bestbuy_price.push(item.at_css('N/A'))
			else
				# if bestbuy_price.length < 5
		  			bestbuy_price.push(item.at_css('.medium-item-price').text)
		  		# end
		  	end
		end
		
		@bestbuy = bestbuy_dump.zip(bestbuy_price)
			render '/mains/index'
	end

end

	