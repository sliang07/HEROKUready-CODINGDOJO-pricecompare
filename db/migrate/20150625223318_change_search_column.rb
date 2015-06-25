class ChangeSearchColumn < ActiveRecord::Migration
  def change
  	rename_column :searches, :searched_term, :search_key
  end
end
