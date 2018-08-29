class Difference < ActiveRecord::Migration[5.2]
  def change
    create_table :differences do |t|
      t.string :catalogue_field
      t.string :catalogue_value
      t.string :rvparky_field
      t.string :rvparky_value
      t.integer :kind

      t.timestamps
    end
  end
end
