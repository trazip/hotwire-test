class Availability < ApplicationRecord
  belongs_to :room
  # after_validation :convert_string_to_date_time

  # def convert_string_to_date_time
  #   date = week_day.zero? ? "1-11-2020" : "#{week_day}-03-2021"
  #   self.starts_at = DateTime.parse("#{date}  #{starts_at} ")
  #   self.ends_at = DateTime.parse("#{date}  #{ends_at} ")
  # end
end
