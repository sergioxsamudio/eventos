class EventUser < ApplicationRecord
  belongs_to :event
  belongs_to :user
  validates :user_id, uniqueness: { scope: :event_id, message: "ya está registrado en este evento" }
end
