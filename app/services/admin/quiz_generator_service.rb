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
      # On cherche un nom pour la question (Designer ou premier Domaine trouvé)
      correct_answer_content = ref.designers.first&.nom_designer || ref.domaines.first&.domaine
      next if correct_answer_content.blank? # On saute si on n'a pas de réponse valable

      question = quiz.quiz_questions.build(
        content: "À quel designer ou mouvement associez-vous cette œuvre : '#{ref.nom_reference}' ?",
        reference_id: ref.id
      )

      # Ajouter la bonne réponse
      question.quiz_answers.build(content: correct_answer_content, is_correct: true)

      # Ajouter des mauvaises réponses (on pioche d'autres designers au hasard)
      wrong_designers = Designer.where(validation: true)
                                .where("nom IS NOT NULL AND nom != ''")
                                .order("RANDOM()")
                                .limit(10) # On en prend un peu plus pour filtrer en Ruby
      
      wrong_count = 0
      wrong_designers.each do |d|
        name = d.nom_designer
        next if name == correct_answer_content || name.blank?
        
        question.quiz_answers.build(content: name, is_correct: false)
        wrong_count += 1
        break if wrong_count >= 3
      end

      # Si on n'a pas assez de designers, on pioche dans les domaines
      if question.quiz_answers.size < 4
        Domaine.where.not(domaine: [nil, "", correct_answer_content]).order("RANDOM()").limit(4 - question.quiz_answers.size).each do |dom|
          question.quiz_answers.build(content: dom.domaine, is_correct: false)
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
