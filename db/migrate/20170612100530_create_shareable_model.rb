class CreateShareableModel < ActiveRecord::Migration[5.0]
  def change
    create_table :share_models do |t|
      # Sahred resource
      t.references :resource, polymorphic: true, index: true
      # Model who will receive resource
      t.references :shared_to, polymorphic: true, index: true
      # Model who share the resource
      t.references :shared_from, polymorphic: true, index: true
      # Edit permissions
      t.boolean :edit
    end
  end
end
