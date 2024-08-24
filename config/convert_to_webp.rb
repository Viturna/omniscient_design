require 'fileutils'

def convert_to_webp(directories)
  directories.each do |directory|
    unless Dir.exist?(directory)
      puts "Le répertoire spécifié n'existe pas : #{directory}"
      next
    end

    puts "Conversion des images du répertoire : #{directory}"

    Dir.foreach(directory) do |filename|
      next if filename == '.' || filename == '..'
      next unless filename.downcase.end_with?('.png', '.jpg')

      input_path = File.join(directory, filename)
      output_path = File.join(directory, "#{File.basename(filename, '.*')}.webp")

      command = "ffmpeg -i '#{input_path}' '#{output_path}'"
      if system(command)
        puts "Conversion réussie : #{filename} -> #{File.basename(output_path)}"
        # Suppression des fichiers originaux
        File.delete(input_path)
        puts "Fichier supprimé : #{filename}"
      else
        puts "Échec de la conversion : #{filename}"
      end
    end
  end
end

# Liste des répertoires à traiter
image_directories = [
  'app/assets/images/designers/desktop',
  'app/assets/images/designers/mobile',
  'app/assets/images/oeuvres/desktop',
  'app/assets/images/oeuvres/mobile'
]

convert_to_webp(image_directories)
