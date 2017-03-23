class EventDetail < ActiveRecord::Base
  include StringNormalizer

  belongs_to :event
  has_many :event_detail_topics
  has_many :topics, through: :event_detail_topics
  accepts_nested_attributes_for :topics

  before_validation do
    self.detail_for_index = normalize_as_string(detail) if detail
  end
end
