namespace :references do
  desc "Send daily reference notification and email"
  task send_daily: :environment do
    Time.use_zone('Paris') do
      if Time.zone.now.to_date.on_weekend?
        puts "Aujourd'hui, c'est le weekend à Paris. On se repose !"
        next
      end

      puts "Checking for daily reference discovery (Paris time: #{Time.zone.now})..."
      DailyReferenceService.call
      puts "Daily reference discovery sent successfully."
    end
  rescue => e
    puts "Error during daily reference discovery: #{e.message}"
    Rails.logger.error "DailyReferenceDiscoveryError: #{e.message}"
  end
end
