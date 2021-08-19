class CreateAvailabilities < ActiveRecord::Migration[6.1]
  def change
    create_table :availabilities do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :week_day
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
