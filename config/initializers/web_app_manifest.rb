Rails.application.config.assets.configure do |env|
  mime_type = 'application/manifest+json'
  extensions = ['.webmanifest']

  if Sprockets::VERSION.to_i >= 4
    extensions << '.webmanifest.erb'
    env.register_preprocessor(mime_type, Sprockets::ERBProcessor)
  end

  env.register_mime_type(mime_type, extensions: extensions)
end
