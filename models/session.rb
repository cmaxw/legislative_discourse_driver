class Session < ActiveRecord::Base
  has_many :bills

  def year
    tag.to_i
  end
end
