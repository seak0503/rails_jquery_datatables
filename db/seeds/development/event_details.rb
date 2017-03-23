Event.all.each do |event|
  3.times.each do
    EventDetail.create!(
      event_id: event.id,
      detail: Faker::Book.title
    )
  end
end