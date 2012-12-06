class DenormalizeParentOffers < ActiveRecord::Migration
  def change
    add_column :offers, :is_parent_offer, :bool, default: false
    add_index "offers", ["is_parent_offer"], :name => "index_offers_on_is_parent_offer"
  end
end
