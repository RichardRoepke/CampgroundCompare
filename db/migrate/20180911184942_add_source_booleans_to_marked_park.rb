class AddSourceBooleansToMarkedPark < ActiveRecord::Migration[5.2]
  def change
    add_column :marked_parks, :rvparky_connection, :boolean, default: false
    add_column :marked_parks, :catalogue_connection, :boolean, default: false
  end
end
