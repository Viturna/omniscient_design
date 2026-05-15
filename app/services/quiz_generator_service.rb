class QuizGeneratorService
  def initialize(list, user)
    @list = list
    @user = user
  end

  def call
    quiz = Quiz.create!(
      title: "Quiz : #{@list.name}",
      description: "Quiz généré à partir de votre liste #{@list.name}",
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
    possible_types = [:designer_from_ref, :ref_from_designer]
    
    has_image = reference.reference_images.first&.file&.attached?
    if has_image
      possible_types << :name_from_image
      possible_types << :image_from_ref
    end

    has_date = reference.date_reference.present?
    if has_date
      possible_types << :year_from_ref
    end

    type = possible_types.sample

    case type
    when :designer_from_ref
      content = "Qui est le designer de la référence \"#{reference.nom_reference}\" ?"
      correct_answer = reference.designers.first&.nom_designer || reference.nom_designer || "Inconnu"
      distractors = Designer.where.not(id: reference.designer_ids).limit(3).order("RANDOM()").map(&:nom_designer)
    
    when :ref_from_designer
      designer_name = reference.designers.first&.nom_designer || reference.nom_designer || "ce designer"
      content = "Laquelle de ces références a été créée par #{designer_name} ?"
      correct_answer = reference.nom_reference
      distractors = Reference.where.not(id: reference.id).limit(3).order("RANDOM()").map(&:nom_reference)
    
    when :name_from_image
      content = "Quel est le nom de cette référence ?"
      correct_answer = reference.nom_reference
      distractors = Reference.where.not(id: reference.id).limit(3).order("RANDOM()").map(&:nom_reference)
    
    when :image_from_ref
      content = "Quelle image correspond à la référence \"#{reference.nom_reference}\" ?"
      correct_answer = get_image_url(reference)
      # On s'assure que les distracteurs ont aussi des images
      distractors = Reference.where.not(id: reference.id)
                             .joins(:reference_images)
                             .limit(3)
                             .order("RANDOM()")
                             .map { |r| get_image_url(r) }
    
    when :year_from_ref
      year = reference.date_reference
      content = "En quelle année la référence \"#{reference.nom_reference}\" a-t-elle été créée ?"
      correct_answer = year.to_s
      
      current_year = Time.current.year
      offsets = [5, -5, 10, -10, 15, -15, 20, -20, 25, -25].shuffle
      wrong_years = []
      offsets.each do |offset|
        y = year + offset
        if y <= current_year && y != year && !wrong_years.include?(y)
          wrong_years << y
        end
        break if wrong_years.size >= 3
      end
      distractors = wrong_years.map(&:to_s)
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

  def get_image_url(reference)
    image = reference.reference_images.first
    return nil unless image&.file&.attached?
    
    Rails.application.routes.url_helpers.rails_blob_url(image.file, only_path: true)
  rescue
    nil
  end
end
