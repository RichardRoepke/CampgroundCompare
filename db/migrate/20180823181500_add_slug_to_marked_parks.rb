class AddSlugToMarkedParks < ActiveRecord::Migration[5.2]
  def change
    add_column :marked_parks, :slug, :string
  end
end
