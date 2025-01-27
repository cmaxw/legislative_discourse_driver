# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  name       :string
#  tag        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Session < ActiveRecord::Base
  has_many :bills

  def year
    tag.to_i
  end
end
