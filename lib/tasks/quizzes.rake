namespace :quizzes do
  desc 'Génère les nouveaux quiz pour la semaine (15, 10, 5) et archive les anciens'
  task generate_weekly: :environment do
    puts '🚀 Début de la génération hebdomadaire des quiz...'

    # 1. Archiver les quiz statiques de plus de 14 jours
    old_quizzes = Quiz.where(quiz_type: 'static', archived: false)
                      .where('created_at < ?', 14.days.ago.beginning_of_day)

    count = old_quizzes.count
    old_quizzes.update_all(archived: true)
    puts "📦 #{count} quiz archivés (plus de 14 jours)."

    # 2. Générer les nouveaux quiz
    [15, 10, 5].each do |q_count|
      puts "👉 Génération des quiz de #{q_count} questions..."
      Domaine.find_each do |domaine|
        quiz = Admin::QuizGeneratorService.new(
          title: "Quiz : #{domaine.domaine}",
          domaine_id: domaine.id,
          count: q_count
        ).call
        puts "   ✅ Succès pour '#{domaine.domaine}' (ID: #{quiz.id})"
      rescue StandardError => e
        puts "   ❌ Erreur pour '#{domaine.domaine}': #{e.message}"
      end
    end

    puts '✨ Terminé ! Les nouveaux quiz sont en ligne.'
  end
  desc 'Réinitialise les points de saison de tous les utilisateurs (à exécuter chaque mois)'
  task reset_monthly_points: :environment do
    puts '🔄 Début de la réinitialisation des points de saison...'

    # 1. Sauvegarder le top 10 de la saison
    top_users = User.where('quiz_points > 0')
                    .order(quiz_points: :desc)
                    .limit(10)
                    .map do |u|
                      {
                        id: u.id,
                        pseudo: u.pseudo,
                        points: u.quiz_points
                      }
                    end

    SeasonHistory.create!(
      month: Date.today.beginning_of_month,
      top_users: top_users
    )
    puts "💾 Historique de la saison sauvegardé avec #{top_users.count} joueurs dans le top."

    # 2. Distribuer les badges Compétiteur au Top 3
    top_3_users = User.where('quiz_points > 0').order(quiz_points: :desc).limit(3)
    top_3_users.each do |user|
      GamificationService.new(user).check_competitor
    end
    puts '🏆 Badges Compétiteur distribués au Top 3 de la saison.'

    # 3. Réinitialiser
    User.update_all(quiz_points: 0)
    puts '✅ Points de saison réinitialisés pour tous les utilisateurs.'
  end
end
