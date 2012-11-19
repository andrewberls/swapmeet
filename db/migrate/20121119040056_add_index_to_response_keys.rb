class AddIndexToResponseKeys < ActiveRecord::Migration
  def change
    add_index :responses, :offer_id
  end
end
