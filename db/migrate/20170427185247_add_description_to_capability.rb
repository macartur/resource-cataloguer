class AddDescriptionToCapability < ActiveRecord::Migration[5.0]
  def change
    add_column :capabilities, :description, :string
  end
end
