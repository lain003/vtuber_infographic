# == Schema Information
#
# Table name: movies
#
#  id               :integer          not null, primary key
#  youtube_movie_id :string
#  youtuber_id      :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Movie < ApplicationRecord
  belongs_to :youtuber
end
