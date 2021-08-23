class Appointment < ApplicationRecord
  belongs_to :user
  belongs_to :room
  validates_uniqueness_of :starts_at, :ends_at, scope: :room_id

  before_create do
    self.week_day = starts_at.wday
  end
end
