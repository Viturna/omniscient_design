require 'mini_magick'

namespace :images do
  desc "Generate thumbnails for oeuvre and designer images"
  task generate_thumbs: :environment do
    # Pour œuvres
    oeuvre_input_dir = Rails.root.join('app', 'assets', 'images', 'oeuvres', 'desktop')
    oeuvre_output_dir = Rails.root.join('app', 'assets', 'images', 'oeuvres', 'thumbs')
    FileUtils.mkdir_p(oeuvre_output_dir)

    Dir.glob("#{oeuvre_input_dir}/*.webp").each do |image_path|
      basename = File.basename(image_path)
      output_path = oeuvre_output_dir.join(basename)

      image = MiniMagick::Image.open(image_path)
      image.resize "300x300^"
      image.gravity "center center"
      image.extent "300x300"
      image.write(output_path)

      puts "Thumbnail generated for oeuvre: #{basename}"
    end

    # Pour designers
    designer_input_dir = Rails.root.join('app', 'assets', 'images', 'designers', 'desktop')
    designer_output_dir = Rails.root.join('app', 'assets', 'images', 'designers', 'thumbs')
    FileUtils.mkdir_p(designer_output_dir)

    Dir.glob("#{designer_input_dir}/*.webp").each do |image_path|
      basename = File.basename(image_path)
      output_path = designer_output_dir.join(basename)

      image = MiniMagick::Image.open(image_path)
      image.resize "300x300^"
      image.gravity "center"
      image.extent "300x300"
      image.write(output_path)

      puts "Thumbnail generated for designer: #{basename}"
    end
  end
end
