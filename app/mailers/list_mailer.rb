class ListMailer < ApplicationMailer
  def invite_editor(list, invited_user, inviting_user, role)
    @list          = list
    @invited_user  = invited_user
    @inviting_user = inviting_user
    @role          = role

    mail(
      to:       @invited_user.email,
      subject:  I18n.t('mailer.list_editor.subject', list: @list.name)
    )
  end
end
