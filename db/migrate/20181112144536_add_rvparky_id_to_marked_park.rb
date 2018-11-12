class AddRvparkyIdToMarkedPark < ActiveRecord::Migration[5.2]
  def change
    add_column :marked_park, :rvparky_id, :integer
  end
end
