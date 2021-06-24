class CreateOffices < ActiveRecord::Migration[5.2]
  def change
    create_table :offices do |t|
      t.string :userlocal_id
      t.string :name

      t.timestamps
    end
    add_index :offices, :userlocal_id
    add_index :offices, :name
  end
end
