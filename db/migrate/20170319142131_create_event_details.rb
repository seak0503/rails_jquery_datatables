class CreateEventDetails < ActiveRecord::Migration
  def change
    create_table :event_details do |t|
      t.string :detail
      t.string :detail_for_index
      t.integer :event_id

      t.timestamps
    end

    add_index :event_details, :detail_for_index
  end
end
