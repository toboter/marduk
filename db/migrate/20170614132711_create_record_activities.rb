class CreateRecordActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :record_activities do |t|
      t.references :user, foreign_key: true
      t.string :resource_type
      t.integer :resource_id
      t.string :activity_type

      t.timestamps
    end
  end
end
