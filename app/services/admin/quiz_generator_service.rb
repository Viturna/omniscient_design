class Admin::QuizGeneratorService
  def initialize(params)
    @title = params[:title]
    @domaine_id = params[:domaine_id]
    @count = params[:count].to_i
    @domaine = Domaine.find(@domaine_id) if @domaine_id.present?
  end

  def call
    quiz = Quiz.new(
      title: @title,
      domaine: @domaine,
      quiz_type: 'static',
      estimated_time: (@count * 0.5).ceil # 30 secondes par question
    )

    # Récupérer des références du domaine (ou toutes si pas de domaine)
    references = if @domaine
      @domaine.references.where(validation: true).order("RANDOM()").limit(@count)
    else
      Reference.where(validation: true).order("RANDOM()").limit(@count)
    end

    if references.empty?
      raise "Aucune référence validée trouvée pour ce domaine. Impossible de générer le quiz."
    end

    references.each do |ref|
      # Choisir un type de question aléatoirement parmi les données disponibles
      available_types = []
      available_types << :designer if ref.designers.any?
      available_types << :date if ref.date_reference.present?
      available_types << :domaine if ref.domaines.any?
      
      type = available_types.sample
      next if type.nil?

      case type
      when :designer
        correct_answer = ref.designers.first.nom_designer
        question = quiz.quiz_questions.build(
          content: "À quel designer associez-vous cette référence : '#{ref.nom_reference}' ?",
          reference_id: ref.id
        )
        # Distracteurs : autres designers
        wrong_pool = Designer.where.not(id: ref.designer_ids).where(validation: true).order("RANDOM()").limit(3)
        wrong_pool.each { |d| question.quiz_answers.build(content: d.nom_designer, is_correct: false) }
        
      when :date
        correct_answer = ref.date_reference.to_s
        question = quiz.quiz_questions.build(
          content: "En quelle année a été créée la référence : '#{ref.nom_reference}' ?",
          reference_id: ref.id
        )
        # Distracteurs : années proches (+/- 2, 5, 10 ans)
        [2, -2, 5, -5, 10, -10].sample(3).each do |offset|
          question.quiz_answers.build(content: (ref.date_reference + offset).to_s, is_correct: false)
        end

      when :domaine
        correct_answer = ref.domaines.first.domaine
        question = quiz.quiz_questions.build(
          content: "À quel domaine appartient la référence : '#{ref.nom_reference}' ?",
          reference_id: ref.id
        )
        # Distracteurs : autres domaines
        wrong_pool = Domaine.where.not(id: ref.domaine_ids).order("RANDOM()").limit(3)
        wrong_pool.each { |d| question.quiz_answers.build(content: d.domaine, is_correct: false) }
      end

      # Ajouter la bonne réponse
      question.quiz_answers.build(content: correct_answer, is_correct: true) if question

      # Compléter à 4 réponses si nécessaire
      if question && question.quiz_answers.size < 4
        (4 - question.quiz_answers.size).times do
          question.quiz_answers.build(content: "Autre option", is_correct: false)
        end
      end
    end

    if quiz.quiz_questions.empty?
      raise "Impossible de générer des questions valables avec les données actuelles."
    end

    quiz.save!
    quiz
  end
end
