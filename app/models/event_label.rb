class EventLabel < ApplicationRecord
  belongs_to :event
  belongs_to :label
end
