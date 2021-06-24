# == Schema Information
#
# Table name: links
#
#  id          :integer          not null, primary key
#  movie_id    :integer
#  youtuber_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Link < ApplicationRecord
  belongs_to :movie
  belongs_to :youtuber
end
