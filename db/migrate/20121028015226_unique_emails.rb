class UniqueEmails < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.index :email, :unique => true
    end
  end
end
