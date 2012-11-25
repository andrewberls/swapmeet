class AddIndexesOnForeignKeys < ActiveRecord::Migration
  def change
    add_index :responses, :bid_id
    add_index :messages, :sender_id
    add_index :messages, :recipient_id
    add_index :offers, :user_id
  end
end
