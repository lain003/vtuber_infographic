class CreateMovies < ActiveRecord::Migration[5.2]
  def change
    create_table :movies do |t|
      t.string :youtube_movie_id
      t.references :youtuber, foreign_key: true

      t.timestamps
    end
    add_index :movies, :youtube_movie_id, :unique => true
  end
end
