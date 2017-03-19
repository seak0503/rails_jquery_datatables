class CreateEventDetails < ActiveRecord::Migration
  def change
    create_table :event_details do |t|
      t.string :detail
      t.integer :event_id

      t.timestamps
    end
  end
end
