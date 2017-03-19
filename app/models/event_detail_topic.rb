class EventDetailTopic < ActiveRecord::Base
  belongs_to :event_detail
  belongs_to :topic
end
