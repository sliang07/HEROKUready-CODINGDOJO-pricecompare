require "open-uri"

class MainsController < ApplicationController


	def new
		if signed_in? == false
			deny_access
		end
		@searchedhistory = Search.all.where(user_id: session[:user_id])
	end
	def create		
		@search = Search.new(search_params)
		if @search.save
			totalsearches = Search.all.where(user_id: session[:user_id]).count
			if totalsearches == 6
				Search.all.where(user_id: session[:user_id]).first.destroy
			end
			item_plus = search_params[:search_key]
			item_underscore = search_params[:search_key]
			i = 0
			for i in 0..item_plus.length
				if item_plus[i] == " "
					item_underscore[i] = "_"
					item_plus[i] = "+"
				end
				i = i + 1
			end

			# AMAZON
		url = "http://www.amazon.com/s/field-keywords=#{item_plus}"

		amazon_dump = Array.new
		amazon_price = Array.new
		amazon_image = Array.new
		amazon_link = Array.new
		amazon_rating = Array.new

		amazon_page = Nokogiri::HTML(open(url))
		amazon_search_result = amazon_page.css('.s-result-item')

		amazon_search_result.each do |item|
			amazon_rating.push(item.css('.a-popover-trigger.a-declarative span').text)		
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
		@amazon = amazon_dump.zip(amazon_price,	amazon_image, amazon_link, amazon_rating)

		

		# WALMART
		url = "http://www.walmart.com/search/search-ng.do?search_constraint=0&ic=48_0&search_query=#{item_underscore}&Find.x=0&Find.y=0&Find=Find"
		walmart_dump = Array.new
		walmart_price = Array.new
		walmart_image = Array.new
		walmart_link = Array.new
		walmart_rating = Array.new

		walmart_page = Nokogiri::HTML(open(url))
		walmart_page.css(".js-tile.tile-landscape").each do |item|
			walmart_rating.push(item.css('.js-reviews').text)
			walmart_link.push(item.css('h4.tile-heading a').map {|a| a['href']})
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
		
		@walmart = walmart_dump.zip(walmart_price,walmart_image, walmart_link, walmart_rating)

		# BESTBUY
		url = "http://www.bestbuy.com/site/searchpage.jsp?st=#{item_plus}&_dyncharset=UTF-8&id=pcat17071&type=page&sc=Global&cp=1&nrp=15&sp=&qp=&list=n&iht=y&usc=All+Categories&ks=960&keys=keys"
		bestbuy_dump = Array.new
		bestbuy_price = Array.new
		bestbuy_image = Array.new
		bestbuy_link = Array.new
		bestbuy_rating = Array.new

		bestbuy_page = Nokogiri::HTML(open(url))
		bestbuy_page.css(".list-item").each do |item|
			bestbuy_rating.push(item.css('.average-score').text)
			bestbuy_link.push(item.css('.sku-title h4 a').map {|a| a['href']})
			if bestbuy_image.length < 5
				bestbuy_image.push(item.css('.thumb img').map { |img| img['src'] })
			end

			if bestbuy_dump.length < 5
				bestbuy_dump.push(item.at_css('.sku-title').text)
			end
			if item.at_css('.medium-item-price').nil?
			bestbuy_dump.pop()
			else
				if bestbuy_price.length < 5
		  			bestbuy_price.push(item.at_css('.medium-item-price').text)
		  		end
		  	end
		end
		
		@bestbuy = bestbuy_dump.zip(bestbuy_price, bestbuy_image, bestbuy_link, bestbuy_rating)

		# TARGET
		url = "http://www.target.com/s?searchTerm=#{item_plus}&category=0%7CAll%7Cmatchallpartial%7Call+categories&lnk=snav_sbox_#{item_plus}"
		target_dump = Array.new
		target_price = Array.new
		target_image = Array.new
		target_link = Array.new
		target_rating = Array.new

		target_page = Nokogiri::HTML(open(url))
		target_page.css(".tile.standard").each do |item|
			target_rating.push(item.css('span.rating-count').text)
			target_link.push(item.css('.tileImage a').map {|a| a['href']})
			if target_image.length < 5
				target_image.push(item.css('.tileImage').map { |img| img['src'] })
			end

			if target_dump.length < 5
				target_dump.push(item.css('.productClick.productTitle').text)
			end
			if item.at_css('.price.price-label').nil?
			target_dump.pop()
			else
				if target_price.length < 5
		  			target_price.push(item.css('p.price.price-label').text)
		  		end
		  	end
		end
		
		@target = target_dump.zip(target_price, target_image,target_link, target_rating)

		# NEWEGG
		url = "http://www.newegg.com/Product/ProductList.aspx?Submit=ENE&DEPA=0&Order=BESTMATCH&Description=#{item_underscore}&N=-1&isNodeId=1"
		newegg_dump = Array.new
		newegg_price = Array.new
		newegg_image = Array.new
		newegg_link = Array.new
		newegg_rating = Array.new

		newegg_page = Nokogiri::HTML(open(url))
		newegg_page.css(".itemCell").each do |item|
			newegg_rating.push(item.css('.itemRating').map {|a| a['title']})
			newegg_link.push(item.css('.wrapper a').map {|a| a['href']})
			if newegg_image	.length < 5
				newegg_image.push(item.css('.itemImage img').map { |img| img['src'] })
			end

			if newegg_dump.length < 5
				newegg_dump.push(item.at_css('.itemDescription').text)
			end
			if item.at_css('.price-current').nil?
			newegg_dump.pop()
			else
				if newegg_price.length < 5
		  			newegg_price.push(item.at_css('.price-current').text)
		  		end
		  	end
		end
		
		@newegg = newegg_dump.zip(newegg_price, newegg_image,newegg_link, newegg_rating)
			render '/mains/index'
	else
		flash[:error] = @search.errors.full_messages
		redirect_to new_main_path
	end
	end
	private
	def search_params
		params.require(:user).permit(:search_key, :user_id)
	end
end

	
