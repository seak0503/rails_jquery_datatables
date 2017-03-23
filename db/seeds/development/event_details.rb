Event.all.each do |event|
  EventDetail.create!(
    event_id: event.id,
    detail: Faker::Book.title
  )
end