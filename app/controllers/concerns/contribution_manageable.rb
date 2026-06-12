module ContributionManageable
  extend ActiveSupport::Concern

  private

  def create_author_notification(record)
    return unless record.user_id.present?

    class_name = record.class.name.downcase
    edit_path = send("edit_#{class_name}_path", record)

    Notification.create(
      user_id: record.user_id,
      notifiable: record,
      title: 'Contribution reçue',
      message: 'Nous avons bien reçu ta contribution ! Elle sera traitée dans les plus brefs délais. Si tu souhaites la modifier avant sa validation, clique ici.',
      link: edit_path
    )
  end

  def handle_destroy(record, success_message)
    if record.destroy
      create_rejection_notification(record)
      update_suivi_references_refusees(record.user)

      respond_to do |format|
        format.html { redirect_to validation_path, notice: success_message }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html do
          redirect_to validation_path, alert: "Une erreur est survenue lors de la suppression."
        end
        format.json { render json: record.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_suivi_references_emises(user)
    return unless user
    suivi = user.suivis.first_or_create
    suivi.increment!(:nb_references_emises)
  end

  def update_suivi_references_validees(user)
    return unless user
    suivi = user.suivis.first_or_create
    suivi.increment!(:nb_references_validees)
  end

  def update_suivi_references_refusees(user)
    return unless user
    suivi = user.suivis.first_or_create
    suivi.increment!(:nb_references_refusees)
  end

  def get_record_name(record)
    if record.class.name == 'Reference'
      record.nom_reference
    elsif record.class.name == 'Designer'
      record.nom_designer
    elsif record.respond_to?(:nom)
      record.nom
    else
      "Contribution"
    end
  end

  def create_notification(record)
    class_name = record.class.name.downcase
    name = get_record_name(record)
    title = "Nouveau/Nouvelle #{class_name} à valider"
    message = I18n.t("notifications.new_#{class_name}", name: name, default: "À valider : #{name}")

    recipients = User.where('role = ? OR certified = ?', 'admin', true)
    recipients.each do |user|
      Notification.create(user_id: user.id, notifiable: record, title: title, message: message)
    end
  end

  def create_validation_notification(record)
    class_name = record.class.name.downcase
    name = get_record_name(record)
    title = "#{class_name.capitalize} validé(e)"
    message = I18n.t("notifications.#{class_name}_validated", name: name, default: "#{name} a été validé(e).")

    if record.user_id.present?
      Notification.create(user_id: record.user_id, notifiable: record, title: title, message: message)
    else
      Notification.create(notifiable: record, title: title, message: message)
    end
  rescue ActiveRecord::NotNullViolation => e
    Rails.logger.error(I18n.t('notifications.error_creation', error: e.message, default: "Erreur : #{e.message}"))
  end

  def create_rejection_notification(record)
    if record.user_id.present?
      class_name = record.class.name.downcase
      name = get_record_name(record)
      title = "#{class_name.capitalize} refusé(e)"
      message = I18n.t("notifications.#{class_name}_rejected", name: name, default: "#{name} a été refusé(e).")

      Notification.create(user_id: record.user_id, notifiable: record, title: title, message: message)
    end
  end

  def notify_admin_of_update(record)
    name = get_record_name(record)
    title = 'Contribution modifiée'
    message = "L'auteur a modifié sa contribution : #{name}"

    recipients = User.where('role = ? OR certified = ?', 'admin', true)
    recipients.each do |user|
      Notification.create(
        user_id: user.id,
        notifiable: record,
        title: title,
        message: message
      )
    end
  end
end
