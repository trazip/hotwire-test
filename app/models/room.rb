class Room < ApplicationRecord
  has_many :availabilities, dependent: :destroy
  has_many :appointments, dependent: :destroy
  accepts_nested_attributes_for :availabilities, allow_destroy: true

  after_create :create_availabilities

  after_update_commit { broadcast_replace_to 'rooms' }
  after_destroy_commit { broadcast_remove_to 'rooms' }

  def create_availabilities
    7.times { |i| Availability.create(starts_at: '9:00', ends_at: '17:00', week_day: i + 1, room_id: id) }
  end

  def availabilities_from(received_date, slot_duration)
    date = today?(received_date) ? DateTime.now : DateTime.parse(received_date)

    availabilities = fetch_and_transform_availabilities(id, date)
    appointments = fetch_appointments(id, date)
    substract_appointments_from_availabilities(availabilities, appointments, date, slot_duration)
  end

  private

  def today?(date)
    date == Date.today.to_s
  end

  def modify_availability(availability, date)
    loop do
      availability.starts_at += 7 * 24 * 3600
      availability.ends_at += 7 * 24 * 3600
      break if availability.starts_at.to_date == date.to_date
    end

    availability
  end

  def fetch_and_transform_availabilities(room_id, date)
    availabilities = Availability.where('room_id = ? AND week_day = ?', room_id, date.wday)
    availabilities.map { |availability| modify_availability(availability, date) }
  end

  def fetch_appointments(room_id, date)
    Appointment.where('room_id = ? AND starts_at >= ? AND ends_at <= ?', room_id, date.beginning_of_day, date.end_of_day)
  end

  def split_time_range(starts_at, ends_at, slot_duration = 30)
    time_range = []

    while starts_at < ends_at
      time_range << starts_at.strftime("%H:%M")
      starts_at += (60 * slot_duration)
    end

    time_range.flatten
  end

  def substract_appointments_from_availabilities(availabilities, appointments, date, slot_duration)
    availabilities = availabilities.map { |availability| split_time_range(availability.starts_at, availability.ends_at, slot_duration) }.flatten
    appointments = appointments.map { |appointment| split_time_range(appointment.starts_at, appointment.ends_at, slot_duration) }.flatten
    results = (availabilities - appointments).uniq
    results.reject { |slot| slot <= date.strftime('%H:%M') }
  end
end
