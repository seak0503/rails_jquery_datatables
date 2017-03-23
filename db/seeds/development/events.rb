1500.times.each do
  Event.create!(name: Faker::Book.author)
end
