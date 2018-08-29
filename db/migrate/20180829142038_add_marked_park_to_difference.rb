class AddMarkedParkToDifference < ActiveRecord::Migration[5.2]
  def change
    add_reference :differences, :marked_park, foreign_key: true
  end
end
