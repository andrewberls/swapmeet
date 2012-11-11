class AddMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :sender_id, :nil => false
      t.integer :recipient_id, :nil => false
      t.string :content, :nil => false
      t.boolean :read, :nil => false, :default => false
      t.timestamps
    end
  end
end
