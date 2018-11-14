class AddRvparkyIdToMarkedPark < ActiveRecord::Migration[5.2]
  def change
    add_column :marked_parks, :rvparky_id, :bigint
  end
end
