class AddAppAdminToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :app_admin, :boolean
  end
end
