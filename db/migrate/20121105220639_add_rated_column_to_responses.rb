class AddRatedColumnToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :rated, :boolean, :default => false, :null => false
  end
end
