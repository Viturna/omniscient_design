require 'mini_magick'

namespace :images do
  desc "Generate thumbnails for oeuvre and designer images"
  task generate_thumbs: :environment do
    # === CONFIG ===
    size = 300

    # === ŒUVRES ===
    oeuvre_input_dir  = Rails.root.join('app', 'assets', 'images', 'oeuvres', 'desktop')
    oeuvre_output_dir = Rails.root.join('app', 'assets', 'images', 'oeuvres', 'thumbs')
    FileUtils.mkdir_p(oeuvre_output_dir)

    Dir.glob("#{oeuvre_input_dir}/*.webp").each do |image_path|
      basename    = File.basename(image_path)
      output_path = oeuvre_output_dir.join(basename)

      image = MiniMagick::Image.open(image_path)

      # Étape 1 : remplir le carré en zoomant
      image.resize "#{size}x#{size}^"

      # Étape 2 : crop forcé centré
      image.combine_options do |c|
        c.gravity 'center'
        c.crop    "#{size}x#{size}+0+0"
        c.repage.+
      end

      image.write(output_path)
      puts "✅ Thumbnail generated for oeuvre: #{basename}"
    end

    # === DESIGNERS ===
    designer_input_dir  = Rails.root.join('app', 'assets', 'images', 'designers', 'desktop')
    designer_output_dir = Rails.root.join('app', 'assets', 'images', 'designers', 'thumbs')
    FileUtils.mkdir_p(designer_output_dir)

    Dir.glob("#{designer_input_dir}/*.webp").each do |image_path|
      basename    = File.basename(image_path)
      output_path = designer_output_dir.join(basename)

      image = MiniMagick::Image.open(image_path)
      image.resize "#{size}x#{size}^"
      image.combine_options do |c|
        c.gravity 'center'
        c.crop    "#{size}x#{size}+0+0"
        c.repage.+
      end

      image.write(output_path)
      puts "✅ Thumbnail generated for designer: #{basename}"
    end
  end
end
