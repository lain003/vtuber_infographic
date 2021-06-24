class CreateYoutubers < ActiveRecord::Migration[5.2]
  def change
    create_table :youtubers do |t|
      t.string :userlocal_id
      t.string :youtube_id
      t.string :name
      t.integer :rank

      t.timestamps
    end
    add_index :youtubers, :userlocal_id, :unique => true
    add_index :youtubers, :youtube_id, :unique => true
    add_index :youtubers, :name
    add_index :youtubers, :rank
  end
end
