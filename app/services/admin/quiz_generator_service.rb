class Admin::QuizGeneratorService
  def initialize(params)
    @title = params[:title]
    @domaine_id = params[:domaine_id]
    @count = [params[:count].to_i, 25].min
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
      available_types = []
      # Choisir un type de question aléatoirement parmi les données disponibles
      # Priorité aux designers : si un designer est présent, on augmente ses chances
      # (on l'ajoute deux fois dans la liste pour doubler sa probabilité)
      available_types << :designer if ref.designers.any?
      available_types << :designer if ref.designers.any? 
      
      available_types << :date if ref.date_reference.present?
      
      has_image = ref.reference_images.any? && ref.reference_images.first.file.attached?
      if has_image
        available_types << :name_from_image
        available_types << :image_from_name
      end
      
      type = available_types.sample
      next if type.nil?

      case type
      when :designer
        correct_answer = ref.designers.first.nom_designer
        question = quiz.quiz_questions.build(
          content: "À quel designer associez-vous cette référence : '#{ref.nom_reference}' ?",
          reference_id: ref.id
        )
        wrong_pool = wrong_designers_pool(exclude_ids: ref.designer_ids).limit(3)
        wrong_pool.each { |d| question.quiz_answers.build(content: d.nom_designer, is_correct: false) }
        
      when :date
        correct_answer = ref.date_reference.to_s
        question = quiz.quiz_questions.build(
          content: "En quelle année a été créée la référence : '#{ref.nom_reference}' ?",
          reference_id: ref.id
        )
        current_year = Time.current.year
        offsets = [2, -2, 5, -5, 10, -10, 15, -15, 20, -20].shuffle
        wrong_years = []
        offsets.each do |offset|
          year = ref.date_reference + offset
          if year <= current_year && year != ref.date_reference && !wrong_years.include?(year)
            wrong_years << year
          end
          break if wrong_years.size >= 3
        end
        wrong_years.each { |y| question.quiz_answers.build(content: y.to_s, is_correct: false) }

      when :name_from_image
        correct_answer = ref.nom_reference
        question = quiz.quiz_questions.build(
          content: "Quel est le nom de cette référence ?",
          reference_id: ref.id
        )
        wrong_pool = wrong_references_pool(exclude_id: ref.id).limit(3)
        wrong_pool.each { |r| question.quiz_answers.build(content: r.nom_reference, is_correct: false) }

      when :image_from_name
        correct_answer = get_image_url(ref)
        question = quiz.quiz_questions.build(
          content: "Laquelle de ces images correspond à la référence : '#{ref.nom_reference}' ?",
          reference_id: ref.id
        )
        # Distracteurs : autres références avec images, du même domaine si possible
        wrong_pool = wrong_references_pool(exclude_id: ref.id)
                          .where(id: ReferenceImage.select(:reference_id))
                          .limit(3)
        wrong_pool.each { |r| question.quiz_answers.build(content: get_image_url(r), is_correct: false) }
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

  private

  # Retourne un scope de références distracteurs :
  # - du même domaine si le quiz est filtré par domaine
  # - sinon toutes les références validées
  def wrong_references_pool(exclude_id:)
    pool = Reference.where.not(id: exclude_id).where(validation: true)
    if @domaine
      domain_pool = pool.joins(:domaines).where(domaines: { id: @domaine.id })
      pool = domain_pool if domain_pool.limit(3).count >= 3
    end
    pool.order("RANDOM()")
  end

  def wrong_designers_pool(exclude_ids:)
    pool = Designer.where.not(id: exclude_ids).where(validation: true)
    if @domaine
      domain_pool = pool.joins(:domaines).where(domaines: { id: @domaine.id })
      pool = domain_pool if domain_pool.limit(3).count >= 3
    end
    pool.order("RANDOM()")
  end

  def get_image_url(reference)
    image = reference.reference_images.first
    return nil unless image&.file&.attached?
    
    Rails.application.routes.url_helpers.rails_blob_url(image.file, only_path: true)
  rescue
    nil
  end
end
