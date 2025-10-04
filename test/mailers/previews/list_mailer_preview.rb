class ListMailerPreview < ActionMailer::Preview
  def invite_editor
    inviting_user = User.first  || User.new(email: "owner@example.com", firstname: "Alice")
    invited_user  = User.second || User.new(email: "invite@example.com", firstname: "Bob")
    list          = List.first  || List.new(name: "Projet Démo", share_token: "fake-token-123")

    ListMailer.invite_editor(list, invited_user, inviting_user, "editor")
  end
end
