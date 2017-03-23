class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.string :name_for_index

      t.timestamps
    end

    add_index :events, :name_for_index
  end
end
