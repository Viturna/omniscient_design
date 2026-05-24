every 1.day, at: '4:30 am' do
  rake 'sitemap:refresh'
end

every :monday, at: '3:00 am' do
  rake 'quizzes:generate_weekly'
end

