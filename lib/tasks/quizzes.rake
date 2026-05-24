namespace :quizzes do
  desc "Génère les nouveaux quiz pour la semaine (15, 10, 5) et archive les anciens"
  task generate_weekly: :environment do
    puts "🚀 Début de la génération hebdomadaire des quiz..."
    
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
        begin
          quiz = Admin::QuizGeneratorService.new(
            title: "Quiz : #{domaine.domaine}",
            domaine_id: domaine.id,
            count: q_count
          ).call
          puts "   ✅ Succès pour '#{domaine.domaine}' (ID: #{quiz.id})"
        rescue => e
          puts "   ❌ Erreur pour '#{domaine.domaine}': #{e.message}"
        end
      end
    end

    puts "✨ Terminé ! Les nouveaux quiz sont en ligne."
  end
end
