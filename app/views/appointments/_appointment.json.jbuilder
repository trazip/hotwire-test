json.extract! appointment, :id, :starts_at, :ends_at, :user_id, :room_id, :created_at, :updated_at
json.url appointment_url(appointment, format: :json)
