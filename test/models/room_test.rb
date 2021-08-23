require "test_helper"

class RoomTest < ActiveSupport::TestCase
  def setup
    @room = Room.create(name: 'three')
    @user = users(:one)
    @start_date = Date.today.to_s
  end

  test 'room can have name' do
    assert_equal 'three', @room.name
  end

  test 'room have availabilities' do
    assert_equal 7, @room.availabilities.count
  end

  test '#availabilities_from returns a hash' do
    assert_instance_of Hash, @room.availabilities_from(@start_date, 30)
  end

  test '#availabilities_from returns whose values are arrays' do
    assert_instance_of Array, @room.availabilities_from(@start_date, 30).values.first
  end

  test '#availabilities_from returns 30 minutes slots' do
    assert_equal(
      ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30',
       '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30'],
      @room.availabilities_from(@start_date, 30).values.first
    )
  end

  test '#availabilities_from returns 60 minutes slots' do
    assert_equal(
      ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00'],
      @room.availabilities_from(@start_date, 60).values.first
    )
  end

  test '#availabilities_from returns 120 minutes slots' do
    assert_equal(
      ['09:00', '11:00', '13:00', '15:00'],
      @room.availabilities_from(@start_date, 120).values.first
    )
  end

  test '#availabilities_from returns the slots availables when there are appointments of 60 minutes' do
    Appointment.create(
      starts_at: DateTime.parse("#{Date.today} 9:00"),
      ends_at: DateTime.parse("#{Date.today} 10:00"),
      room_id: @room.id,
      user_id: @user.id
    )

    assert_equal(
      ['-', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00'],
      @room.availabilities_from(@start_date, 60).values.first
    )
  end

  test '#availabilities_from returns the slots availables when there are several appointments of 30 minutes' do
    Appointment.create(
      starts_at: DateTime.parse("#{Date.today} 10:00"),
      ends_at: DateTime.parse("#{Date.today} 10:30"),
      room_id: @room.id,
      user_id: @user.id
    )

    Appointment.create(
      starts_at: DateTime.parse("#{Date.today} 11:30"),
      ends_at: DateTime.parse("#{Date.today} 12:00"),
      room_id: @room.id,
      user_id: @user.id
    )

    assert_equal(
      ['09:00', '09:30', '-', '10:30', '11:00', '-', '12:00', '12:30',
       '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30'],
      @room.availabilities_from(@start_date, 30).values.first
    )
  end

  test 'availabilities are recurrent' do
    assert_equal(
      ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30',
       '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30'],
      @room.availabilities_from((Date.today + 1.week).to_s, 30).values.first
    )
  end

  test "there can't be duplicate appointments" do
    Appointment.create(
      starts_at: DateTime.parse("#{Date.today} 10:00"),
      ends_at: DateTime.parse("#{Date.today} 10:30"),
      room_id: @room.id,
      user_id: users(:one).id
    )

    Appointment.create(
      starts_at: DateTime.parse("#{Date.today} 10:00"),
      ends_at: DateTime.parse("#{Date.today} 10:30"),
      room_id: @room.id,
      user_id: users(:two).id
    )

    assert_equal 1, @room.appointments.count
  end

  test 'it can generate different week_durations' do
    assert_equal 4, @room.availabilities_from(@start_date, 30, 4).keys.count
  end
end
