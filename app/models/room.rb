class Room < ApplicationRecord
  has_many :availabilities, dependent: :destroy
  has_many :appointments, dependent: :destroy
  accepts_nested_attributes_for :availabilities, allow_destroy: true

  after_create :create_availabilities

  after_update_commit { broadcast_replace_to 'rooms' }
  after_destroy_commit { broadcast_remove_to 'rooms' }

  def create_availabilities
    7.times { |i| Availability.create(starts_at: '9:00', ends_at: '17:00', week_day: i, room_id: id) }
  end

  def availabilities_from(date, slot_duration = 30, week_duration = 6)
    date = DateTime.parse(date)
    date_range = generate_date_range(date, week_duration)
    results = generate_results(id, date_range, slot_duration)
    clean_results(results)
  end

  private

  ## Generate a date_range based on a start_date and a duration in days
  def generate_date_range(date, week_duration)
    date.beginning_of_day..(date.end_of_day + week_duration.days - 1.day)
  end

  def generate_results(id, date_range, slot_duration)
    results = format_hash(date_range)
    events = fetch_events(id, date_range)
    week = generate_week(date_range)
    transposed_events = transpose_events(events, week)
    transform_events_in_ranges(transposed_events, results, slot_duration, week)
  end

  def fetch_events(id, date_range)
    Availability.where(room_id: id, week_day: date_range.map(&:wday)) +
      Appointment.where('room_id = ? AND starts_at >= ? AND ends_at <= ?', id, date_range.begin, date_range.end)
  end

  def format_hash(date_range)
    date_range.each_with_object({}) { |day, hash| hash[day.strftime('%Y-%m-%d')] = [[], []] }
  end

  def transpose_events(events, week)
    events.map { |event| event.instance_of?(Availability) ? transform_event(event, week[event.week_day]) : event }
  end

  def generate_week(date_range)
    date_range.each_with_object({}) { |day, hash| hash[day.wday] = day.strftime('%Y-%m-%d') }
  end

  ## Move the date of a single event to the same day in the date_range
  def transform_event(event, day)
    event.starts_at = DateTime.parse("#{day} #{event.starts_at.to_s(:time)}")
    event.ends_at = DateTime.parse("#{day} #{event.ends_at.to_s(:time)}")
    event
  end

  def transform_events_in_ranges(events, results, slot_duration, week)
    events.each do |event|
      day = week[event.week_day]
      if event.instance_of?(Availability)
        availabilities_ranges(event, day, slot_duration, results)
      else
        appointments_ranges(event, day, results)
      end
    end
    results
  end

  def appointments_ranges(event, day, results)
    results[day].second << generate_range(event.starts_at, event.ends_at)
    results
  end

  def availabilities_ranges(event, day, slot_duration, results)
    while event.starts_at < event.ends_at
      results[day].first << generate_range(event.starts_at, event.starts_at + 60 * slot_duration)
      event.starts_at += (60 * slot_duration)
    end
    results
  end

  ## Generate a range for using the start_time and end_time of an event (availability or appointment)
  def generate_range(starts_at, ends_at)
    starts_at.strftime('%H:%M')...ends_at.strftime('%H:%M')
    #starts_at...ends_at
  end

  def clean_results(hash)
    hash.each do |key, _|
      hash[key] = hash[key][0].map do |slot|
        overlap = hash[key][1].map { |booked_slot| (booked_slot).overlaps?(slot) }
        overlap.include?(true) ? '-' : slot
      end
    end
  end



  # availabilities.map do |slot|
  #   overlap = appointments.map { |booked_slot| (booked_slot).overlaps?(slot) }
  #   overlap.include?(true) ? '-' : slot
  # end

end














  #number_of_slots = ((ends_at - starts_at) / 60).to_i / slot_duration
  # durations = Array.new(number_of_slots) { |index| 60 * slot_duration * index }

# i += 1
# event = events[i]

  # def replace_taken_times(first_array, second_array)
  #   first_array.map { |slot| second_array.include?(slot) ? '-' : slot }
  # end



# def availabilities_from(date, slot_duration = 30, week_duration = 6)
  #   date = DateTime.parse(date)
  #   date_range = date.beginning_of_day..(date.end_of_day + week_duration.days - 1.day)
  #   events = fetch(id, date_range)
  #   generate_results(events, date_range, slot_duration)
  # end

  # def fetch(id, date_range)
  #   days = date_range.map(&:wday)
  #   Availability.where(room_id: id, week_day: days) + Appointment.where('room_id = ? AND starts_at >= ? AND ends_at <= ?', id, date_range.begin, date_range.end)
  # end

  # def format_hash(date_range)
  #   date_range.each_with_object({}) { |day, hash| hash[day.strftime('%Y-%m-%d')] = [] }
  # end

  # def generate_week(date_range)
  #   date_range.each_with_object({}) { |day, hash| hash[day.wday] = day.strftime('%Y-%m-%d') }
  # end

  # def split_time_range(starts_at, ends_at, slot_duration = 30)
  #   time_range = []

  #   while starts_at < ends_at
  #     # time_range << [starts_at, starts_at + slot_duration.minutes]
  #     # time_range << starts_at.strftime('%H:%M')
  #     time_range << starts_at
  #     starts_at += (60 * slot_duration)
  #   end

  #   time_range
  # end

  # def transform_event(event, day)
  #   event.starts_at = DateTime.parse("#{day} #{event.starts_at.to_s(:time)}")
  #   event.ends_at = DateTime.parse("#{day} #{event.ends_at.to_s(:time)}")
  #   event
  # end

  # def replace_taken_times(first_array, second_array)
  #   first_array.map { |slot| second_array.include?(slot) ? '-' : slot }
  # end

  # def generate_results(events, date_range, slot_duration)
  #   results = format_hash(date_range)
  #   week = generate_week(date_range)

  #   events.each do |event|
  #     # i += 1
  #     # event = events[i]
  #     day = week[event.week_day]
  #     event = transform_event(event, day)
  #     slots = split_time_range(event.starts_at, event.ends_at, slot_duration)
  #     event.instance_of?(Availability) ? results[day] += slots : results[day] = replace_taken_times(results[day], slots)
  #   end

  #   results
  # end



# def clean_hash(hash)
#   hash.each_value do |array|
#     next unless array.join('').match?(/\d/)

#     array.each do |slot|
#       break if slot.match?(/\d/)

#       array.delete(slot)
#     end
#   end
# end



# time_range << starts_at.strftime("%H:%M")
#time_range << [starts_at.strftime('%FT%T%:z'), (starts_at + 60 * slot_duration).strftime('%FT%T%:z')]

#date_range.map { |day| day.strftime('%Y-%m-%d') }
# def availabilities_from(received_date, slot_duration)
#   date = today?(received_date) ? DateTime.now : DateTime.parse(received_date)

#   availabilities = fetch_and_transform_availabilities(id, date)
#   appointments = fetch_appointments(id, date)
#   substract_appointments_from_availabilities(availabilities, appointments, date, slot_duration)
# end

# private

# def today?(date)
#   date == Date.today.to_s
# end

# def modify_availability(availability, date)
#   loop do
#     availability.starts_at += 7 * 24 * 3600
#     availability.ends_at += 7 * 24 * 3600
#     break if availability.starts_at.to_date == date.to_date
#   end

#   availability
# end

# def fetch_and_transform_availabilities(room_id, date)
#   availabilities = Availability.where('room_id = ? AND week_day = ?', room_id, date.wday)
#   availabilities.map { |availability| modify_availability(availability, date) }
# end

# def fetch_appointments(room_id, date)
#   Appointment.where('room_id = ? AND starts_at >= ? AND ends_at <= ?', room_id, date.beginning_of_day, date.end_of_day)
# end

# def substract_appointments_from_availabilities(availabilities, appointments, date, slot_duration)
#   availabilities = availabilities.map { |availability| split_time_range(availability.starts_at, availability.ends_at, slot_duration) }.flatten
#   appointments = appointments.map { |appointment| split_time_range(appointment.starts_at, appointment.ends_at, slot_duration) }.flatten
#   results = (availabilities - appointments).uniq
#   # results.reject { |slot| slot <= date.strftime('%H:%M') }
# end

# base_time_range.each do |available_slot|
#   overlap = unavailable.map do |booked_slot|
#     (booked_slot[0]...(booked_slot[0] + booked_slot[1].hours)).overlaps?(available_slot...(available_slot + time_range[1].hours))
#   end

#   !overlap.include?(true) ? available_slots << slot : ''
# end

# def split_time_range(starts_at, ends_at, slot_duration = 30)
#   time_range = []

#   while starts_at < ends_at
#     time_range << (starts_at.strftime('%H:%M')...(starts_at + 60 * slot_duration).strftime('%H:%M'))
#     starts_at += (60 * slot_duration)
#   end

#   time_range
# end

# def make_range_for_appointments(appointments)
#   appointments.map do |appointment|
#     appointment.starts_at.strftime('%H:%M')...appointment.ends_at.strftime('%H:%M')
#   end
# end

# availabilities.map do |slot|
#   overlap = appointments.map { |booked_slot| (booked_slot).overlaps?(slot) }
#   overlap.include?(true) ? '-' : slot
# end
