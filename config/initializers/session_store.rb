# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store, 
  key: '_omniscient_design_session',
  expire_after: 1.year