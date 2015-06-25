require "open-uri"

class MainsController < ApplicationController
	def new
		render '/mains/new'
	end
	def create
		item = params[:search_key]

		url = "http://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords=#{item}"
			dump = Array.new
			price = Array.new
			image = Array.new
			link = Array.new
			amazon = Nokogiri::HTML(open(url))
			amazon_search_result = amazon.css('.s-result-item')
			amazon_search_result.each do |item|
				link.push(item.css('.a-row.a-spacing-none a').map {|a| a['href']})
				if image.length < 5
					image.push(item.css('a.a-link-normal.a-text-normal img').map { |img| img['src'] })
				end
				if dump.length < 5
					dump.push(item.css(".a-size-medium.s-inline.s-access-title.a-text-normal").text)
				end
				if item.css('.a-size-base.a-color-price.s-price.a-text-bold').nil?
					dump.pop()
				else
					if price.length < 5
						price.push(item.css('.a-size-base.a-color-price.s-price.a-text-bold').text)
					end
				end
			end
			@amazon = dump.zip(price, image, link)


		url = "http://seattle.craigslist.org/search/sss?query=#{item}&sort=rel"
		craigslist = Nokogiri::HTML(open(url))
		dump = Array.new
		price = Array.new
		craigslist_search_result = craigslist.css(".row")
		craigslist_search_result.each do |item|
		dump.push(item.at_css('.hdrlnk').text.strip)
			if item.at_css('.l2 .price').nil?
				dump.pop()
			else
		  		price.push(item.at_css('.l2 .price').text.strip)
			end
		  
		end

		@craigslist = dump.zip(price)


		url = "http://www.walmart.com/search/search-ng.do?search_constraint=0&ic=48_0&search_query=#{item}&Find.x=0&Find.y=0&Find=Find"
		dump = Array.new
		price = Array.new
		image = Array.new
		walmart = Nokogiri::HTML(open(url))
		walmart.css(".js-tile.tile-landscape").each do |item|
			image.push(item.css('.js-product-image img').map { |img| img['data-default-image'] })
			dump.push(item.at_css('.js-product-title').text)
			if item.at_css('.price-display').nil?
				dump.pop()
			else
		  		price.push(item.at_css('.price-display').text)
		  	end
		end
		
		@walmart = dump.zip(price, image)


		url = "http://www.bestbuy.com/site/searchpage.jsp?st=#{item}&_dyncharset=UTF-8&id=pcat17071&type=page&sc=Global&cp=1&nrp=15&sp=&qp=&list=n&iht=y&usc=All+Categories&ks=960&keys=keys"
		dump = Array.new
		price = Array.new
		image = Array.new
		bestbuy = Nokogiri::HTML(open(url))
		bestbuy.css(".list-item").each do |item|
			image.push(item.css('.thumb img').map { |img| img['src'] })
			dump.push(item.at_css('.sku-title').text)
			if item.at_css('.medium-item-price').nil?
				dump.pop()
			else
		  		price.push(item.at_css('.medium-item-price').text)
		  	end
		end
		
		@bestbuy = dump.zip(price, image)
			render '/mains/index'
	end

end
