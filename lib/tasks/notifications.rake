namespace :notifications do
  desc "Send baccalaureate notifications to all users on specific dates"
  task baccalaureate: :environment do
    today = Date.today
    
    if today == Date.new(2026, 6, 16)
      send_bac_notification("C'est l'heure de l'AMD ! 📝", "C'est le grand jour ! On te souhaite bon courage pour l'épreuve d'AMD. Respire un bon coup, tu vas gérer ! ✨")
    elsif today == Date.new(2026, 6, 17)
      send_bac_notification("Dernière épreuve : la CCDMA ! 🎨", "Dernière épreuve ! Bon courage pour la CCDMA. Donne tout ce qu'il te reste, on commence à voir le bout du tunnel ! ☀️")
    else
      puts "No notification scheduled for today."
    end
  end

  def send_bac_notification(title, message)
    puts "Sending baccalaureate notification: '#{title}' - '#{message}'"
    User.where(study_level: 'Terminale STD2A').find_each do |user|
      Notification.create(
        user: user,
        title: title,
        message: message,
        link: "/"
      )
    end
    puts "Notifications sent to targeted users."
  end
end
