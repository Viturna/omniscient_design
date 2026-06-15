every 1.day, at: '4:30 am' do
  rake 'sitemap:refresh'
end

every :monday, at: '3:00 am' do
  rake 'quizzes:generate_weekly'
end

every 1.month, at: 'start of the month at 0:00 am' do
  rake 'quizzes:reset_monthly_points'
end

every 1.day, at: '7:00 am' do
  rake 'notifications:baccalaureate'
end
