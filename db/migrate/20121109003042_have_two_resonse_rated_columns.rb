class HaveTwoResonseRatedColumns < ActiveRecord::Migration
  def change
    rename_column :responses, :rated, :offerer_rated
    add_column :responses, :bidder_rated, :boolean, :default => false, :null => false
  end
end
