class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.integer :offer_id
      t.integer :bid_id
      t.string :status
      t.timestamps
    end
  end
end
