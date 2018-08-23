class CreateMarkedParks < ActiveRecord::Migration[5.2]
  def change
    create_table :marked_parks do |t|
      t.string :uuid
      t.string :name
      t.string :status

      t.timestamps
    end

    add_index :marked_parks, :uuid, unique: true #To help avoid duplication.
  end
end
