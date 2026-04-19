namespace :references do
  desc "Send daily reference notification and email"
  task send_daily: :environment do
    puts "Checking for daily reference discovery..."
    DailyReferenceService.call
    puts "Daily reference discovery sent successfully."
  rescue => e
    puts "Error during daily reference discovery: #{e.message}"
    Rails.logger.error "DailyReferenceDiscoveryError: #{e.message}"
  end
end
