class CreatePendingParks < ActiveRecord::Migration[5.2]
  def change
    create_table :pending_parks do |t|
      t.string :uuid
      t.string :slug
      t.integer :rvparky_id

      t.timestamps
    end
  end
end
