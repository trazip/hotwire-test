class AddWeekDayToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :week_day, :integer
  end
end
