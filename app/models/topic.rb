class Topic < ActiveRecord::Base
  has_many :event_detail_topics
end
