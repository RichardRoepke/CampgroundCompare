class RemoveIndexFromUuid < ActiveRecord::Migration[5.2]
  def change
    remove_index :marked_parks, :uuid
  end
end
