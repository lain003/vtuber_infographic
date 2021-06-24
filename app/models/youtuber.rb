# == Schema Information
#
# Table name: youtubers
#
#  id           :integer          not null, primary key
#  userlocal_id :string
#  youtube_id   :string
#  name         :string
#  rank         :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  office_id    :integer
#

class Youtuber < ApplicationRecord
  belongs_to :office
end
