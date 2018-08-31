class AddEditabletoMarkedPark < ActiveRecord::Migration[5.2]
  def change
    add_column :marked_parks, :editable, :boolean
  end
end
