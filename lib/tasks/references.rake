namespace :references do
  desc "Send daily reference notification and email"
  task send_daily: :environment do
    if Date.today.on_weekend?
      puts "Aujourd'hui, c'est le weekend. On se repose, pas d'envoi !"
      next
    end

    puts "Checking for daily reference discovery..."
    DailyReferenceService.call
    puts "Daily reference discovery sent successfully."
  rescue => e
    puts "Error during daily reference discovery: #{e.message}"
    Rails.logger.error "DailyReferenceDiscoveryError: #{e.message}"
  end
end
