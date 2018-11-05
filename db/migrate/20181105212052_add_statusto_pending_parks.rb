class AddStatustoPendingParks < ActiveRecord::Migration[5.2]
  def change
    add_column :pending_parks, :status, :integer, default: 0
  end
end
