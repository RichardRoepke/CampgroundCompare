class CreateDifferences < ActiveRecord::Migration[5.2]
  def change
    create_table :differences do |t|
      t.string :catalogue_field
      t.string :rvparky_field
      t.integer :kind

      t.timestamps
    end
  end
end
