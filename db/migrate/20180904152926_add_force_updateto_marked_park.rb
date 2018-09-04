class AddForceUpdatetoMarkedPark < ActiveRecord::Migration[5.2]
  def change
    add_column :marked_parks, :force_update, :boolean, default: false
  end
end
