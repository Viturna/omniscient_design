count_arg = ARGV.find { |arg| arg.start_with?('COUNT=') }
count_val = count_arg ? count_arg.split('=').last : ENV['COUNT']
count = [(count_val || 10).to_i, 25].min
puts "🚀 Lancement de la génération des quiz par domaine (Questions par quiz : #{count})..."

Domaine.all.each do |domaine|
  print "👉 Génération pour le domaine '#{domaine.domaine}'... "
  
  begin
    params = {
      title: "Quiz : #{domaine.domaine}",
      domaine_id: domaine.id,
      count: count
    }
    
    # Utilisation du service Admin que nous avons déjà optimisé
    quiz = Admin::QuizGeneratorService.new(params).call
    
    puts "✅ Succès ! Quiz ID: #{quiz.id}"
  rescue => e
    puts "❌ Erreur : #{e.message}"
  end
end

puts "✨ Terminé ! Tes quiz sont disponibles dans le Hub."
