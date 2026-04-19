class DailyReferenceService
  def self.call
    service = new
    reference = service.pick_for_today
    
    if reference.nil?
      # On utilise deliver_now pour être sûr que l'alerte parte avant la fin de la tâche
      DailyReferenceMailer.admin_stock_alert("contact@omniscientdesign.fr").deliver_now
      return nil
    end

    service.send_notifications
  end

  def pick_for_today
    return @daily_ref.reference if (@daily_ref = DailyReference.for_today)

    # Sélectionner une référence validée
    # On évite celles déjà choisies
    sent_reference_ids = DailyReference.pluck(:reference_id)
    reference = Reference.where(validation: true).where.not(id: sent_reference_ids).order("RANDOM()").first
    return nil unless reference

    @daily_ref = DailyReference.create!(reference: reference, date: Date.today)
    reference
  end

  def send_notifications
    return unless @daily_ref
    reference = @daily_ref.reference
    title = "La réf du jour"
    message = "Aujourd'hui découvre \"#{reference.nom_reference}\" par #{reference.designers.map(&:nom_designer).join(', ')}"
    link = "/fr/references/#{reference.slug}"

    # Notifications Push
    User.where(daily_reference_push: true).find_each do |user|
      Notification.create!(
        user: user,
        title: title,
        message: message,
        link: link,
        status: :unread,
        notifiable: reference
      )
    end

    # Notifications Email
    User.where(daily_reference_email: true).find_each do |user|
      DailyReferenceMailer.daily_discovery(user, reference).deliver_now
    end
  end
end
