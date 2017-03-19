class EventDetail < ActiveRecord::Base
  belongs_to :event
  has_many :event_detail_topics
  has_many :topics, through: :event_detail_topics
  accepts_nested_attributes_for :topics
end
