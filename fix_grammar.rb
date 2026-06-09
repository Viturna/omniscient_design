content = File.read('config/locales/fr.yml')

replacements = {
  "Tu n'avez" => "Tu n'as",
  "Tu avez" => "Tu as",
  "tu ayez" => "tu aies",
  "tu n'ayez" => "tu n'aies",
  "Merci de tu être" => "Merci de t'être",
  "tu informer" => "t'informer",
  "Nous tu contactons" => "Nous te contactons",
  "Nous tu informons" => "Nous t'informons",
  "tu à invité" => "t'a invité",
  "tu a attribué" => "t'a attribué",
  "tu n’attendiez" => "tu n'attendais",
  "Finalisez ton" => "Finalise ton",
  "cliquez sur" => "clique sur",
  "n'hésitez pas" => "n'hésite pas",
  "tu devrez" => "tu devras",
  "tu serez" => "tu seras",
  "Ton fiche" => "Ta fiche",
  "Tu pourrez" => "Tu pourras",
  "tu pouvez" => "tu peux",
  "tu n'avez" => "tu n'as",
  "Tu n’avez" => "Tu n'as"
}

replacements.each do |k, v|
  content.gsub!(k, v)
end

File.write('config/locales/fr.yml', content)
