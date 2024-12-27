class ListMailer < ApplicationMailer
  def invite_editor(list, user)
    @list = list
    @user = user
    mail(to: @user.email, subject: 'Invitation à éditer une liste')
  end
end
