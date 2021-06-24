# == Schema Information
#
# Table name: offices
#
#  id           :integer          not null, primary key
#  userlocal_id :string
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Office < ApplicationRecord
end
