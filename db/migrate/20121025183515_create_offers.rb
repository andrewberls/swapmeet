class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.string :title
      t.text :description

      t.belongs_to :user
      t.timestamps
    end
  end
end
