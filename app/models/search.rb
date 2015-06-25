class Search < ActiveRecord::Base
  belongs_to :users

    validates :search_key,
  			:presence => true
end