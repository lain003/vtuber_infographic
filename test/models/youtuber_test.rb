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

require 'test_helper'

class YoutuberTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
