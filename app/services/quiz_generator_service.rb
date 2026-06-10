class QuizGeneratorService
  def initialize(list, user)
    @list = list
    @user = user
  end

  def call
    quiz = Quiz.create!(
      title: "Quiz : #{@list.name}",
      description: "Quiz généré à partir de ta liste #{@list.name}",
      quiz_type: 'dynamic',
      list: @list
    )

    # Récupérer toutes les références de la liste
    available_references = @list.references.all
    return quiz if available_references.empty?

    # On veut 15 questions (ou au moins 10 comme demandé en dernier)
    # On va boucler pour atteindre 15 questions
    target_count = 15

    (0...target_count).each do |i|
      # On prend une référence en boucle (0, 1, 2, 0, 1, 2...)
      ref = available_references[i % available_references.count]
      generate_question(quiz, ref, i)
    end

    quiz
  end

  private

  def generate_question(quiz, reference, index)
    # On définit les types possibles pour CETTE référence
    possible_types = %i[designer_from_ref ref_from_designer]

    has_image = reference.reference_images.first&.file&.attached?
    if has_image
      possible_types << :name_from_image
      possible_types << :image_from_ref
    end

    has_date = reference.date_reference.present?
    possible_types << :year_from_ref if has_date

    if reference.notions.any? && has_image
      possible_types << :notion_from_ref
      possible_types << :ref_from_notion
    end

    # Définition d'un roulement idéal pour garantir la diversité et favoriser les questions à images
    ideal_rotation = %i[
      name_from_image
      designer_from_ref
      notion_from_ref
      image_from_ref
      year_from_ref
      ref_from_notion
      name_from_image
      ref_from_designer
      image_from_ref
    ]

    preferred_type = ideal_rotation[index % ideal_rotation.length]

    # Si le type préféré est possible, on le prend, sinon on se rabat sur un choix aléatoire possible
    type = possible_types.include?(preferred_type) ? preferred_type : possible_types.sample

    case type
    when :designer_from_ref
      content = "Qui est le designer de la référence \"#{reference.nom_reference}\" ?"
      correct_answer = reference.designers.first&.nom_designer || reference.nom_designer || 'Inconnu'
      distractors = wrong_designers_pool(reference).limit(3).map(&:nom_designer)

    when :ref_from_designer
      designer_name = reference.designers.first&.nom_designer || reference.nom_designer || 'ce designer'
      content = "Laquelle de ces références a été créée par #{designer_name} ?"
      correct_answer = reference.nom_reference
      distractors = wrong_references_pool(reference).limit(3).map(&:nom_reference)

    when :name_from_image
      content = 'Quel est le nom de cette référence ?'
      correct_answer = reference.nom_reference
      distractors = wrong_references_pool(reference).limit(3).map(&:nom_reference)

    when :image_from_ref
      content = "Quelle image correspond à la référence \"#{reference.nom_reference}\" ?"
      correct_answer = "reference_image:#{reference.id}"
      # On s'assure que les distracteurs ont aussi des images
      distractors = wrong_references_pool(reference, with_images: true)
                    .limit(3)
                    .map { |r| "reference_image:#{r.id}" }

    when :year_from_ref
      year = reference.date_reference
      content = "En quelle année la référence \"#{reference.nom_reference}\" a-t-elle été créée ?"
      correct_answer = year.to_s

      current_year = Time.current.year
      offsets = [5, -5, 10, -10, 15, -15, 20, -20, 25, -25].shuffle
      wrong_years = []
      offsets.each do |offset|
        y = year + offset
        wrong_years << y if y <= current_year && y != year && !wrong_years.include?(y)
        break if wrong_years.size >= 3
      end
      distractors = wrong_years.map(&:to_s)

    when :notion_from_ref
      notion = reference.notions.sample
      content = "Quelle notion est associée à la référence \"#{reference.nom_reference}\" ?"
      correct_answer = notion&.name || 'Inconnue'
      distractors = wrong_notions_pool(reference).limit(3).map(&:name)

    when :ref_from_notion
      notion = reference.notions.sample
      content = "Laquelle de ces références est associée à la notion \"#{notion&.name}\" ?"
      correct_answer = reference.nom_reference
      wrong_refs = wrong_references_pool(reference).where.not(id: Reference.joins(:notions).where(notions: { id: notion&.id }).select(:id))
      wrong_refs = wrong_references_pool(reference).where.not(id: reference.id) if wrong_refs.limit(3).count < 3
      distractors = wrong_refs.limit(3).map(&:nom_reference)
    end

    question = quiz.quiz_questions.create!(
      content: content,
      order: index + 1,
      reference_id: reference.id
    )

    # Créer les réponses
    QuizAnswer.create!(quiz_question: question, content: correct_answer, is_correct: true)
    distractors.compact.reject(&:blank?).each do |dist|
      QuizAnswer.create!(quiz_question: question, content: dist, is_correct: false)
    end
  end

  def wrong_references_pool(reference, with_images: false)
    domaine_ids = reference.domaine_ids
    if domaine_ids.any?
      pool = Reference.where.not(id: reference.id).joins(:domaines).where(domaines: { id: domaine_ids })
      pool = pool.joins(:reference_images) if with_images
      pool = pool.distinct

      if pool.limit(3).count < 3
        pool = Reference.where.not(id: reference.id)
        pool = pool.joins(:reference_images) if with_images
      end
    else
      pool = Reference.where.not(id: reference.id)
      pool = pool.joins(:reference_images) if with_images
    end

    # Avoid PG::InvalidColumnReference with SELECT DISTINCT and ORDER BY RANDOM()
    Reference.where(id: pool.select(:id)).order('RANDOM()')
  end

  def wrong_designers_pool(reference)
    domaine_ids = reference.domaine_ids
    if domaine_ids.any?
      pool = Designer.where.not(id: reference.designer_ids).joins(:domaines).where(domaines: { id: domaine_ids }).distinct

      pool = Designer.where.not(id: reference.designer_ids) if pool.limit(3).count < 3
    else
      pool = Designer.where.not(id: reference.designer_ids)
    end

    # Avoid PG::InvalidColumnReference with SELECT DISTINCT and ORDER BY RANDOM()
    Designer.where(id: pool.select(:id)).order('RANDOM()')
  end

  def wrong_notions_pool(reference)
    domaine_ids = reference.domaine_ids
    if domaine_ids.any?
      pool = Notion.where.not(id: reference.notion_ids).joins(references: :domaines).where(domaines: { id: domaine_ids }).distinct

      pool = Notion.where.not(id: reference.notion_ids) if pool.limit(3).count < 3
    else
      pool = Notion.where.not(id: reference.notion_ids)
    end

    Notion.where(id: pool.select(:id)).order('RANDOM()')
  end

  def get_image_url(reference)
    image = reference.reference_images.first
    return nil unless image&.file&.attached?

    Rails.application.routes.url_helpers.rails_blob_url(image.file, only_path: true)
  rescue StandardError
    nil
  end
end
