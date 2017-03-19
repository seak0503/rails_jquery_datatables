class Event < ActiveRecord::Base
  has_many :event_details
  accepts_nested_attributes_for :event_details
end
