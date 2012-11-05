class AddKarmaToUser < ActiveRecord::Migration
  def change
    add_column :users,  :up_ratings, :integer, :default => 0, :null => false
    add_column :users,  :down_ratings, :integer, :default => 0, :null => false
  end
end
