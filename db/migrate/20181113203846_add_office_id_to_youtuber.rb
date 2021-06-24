class AddOfficeIdToYoutuber < ActiveRecord::Migration[5.2]
  def change
    add_reference :youtubers, :office, foreign_key: true
  end
end
