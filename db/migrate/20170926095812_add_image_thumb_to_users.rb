class AddImageThumbToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :image_thumb_url, :string
  end
end
