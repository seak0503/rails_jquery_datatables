class Event < ActiveRecord::Base
  include StringNormalizer

  has_many :event_details
  accepts_nested_attributes_for :event_details

  before_validation do
    self.name_for_index = normalize_as_string(name) if name
  end
end
