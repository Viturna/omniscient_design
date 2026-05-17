namespace :gamification do
  desc "Attribue rétroactivement les badges aux utilisateurs existants"
  task update_badges: :environment do
    puts "🏆 Démarrage de l'attribution rétroactive des badges..."
    
    User.find_each do |user|
      puts "Traitement de l'utilisateur ID: #{user.id} (#{user.email})..."
      
      service = GamificationService.new(user)

      service.check_omniscient_user
      service.check_early_adopter

      service.check_contributor
      service.check_investigator
      service.check_ambassador
      
      service.check_multi_support
      service.check_gamer
      service.check_competitor
    end

    puts "✅ Terminé ! Tous les utilisateurs ont été mis à jour."
  end
end