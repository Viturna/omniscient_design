Rails.application.config.session_store :cookie_store, 
  key: '_omniscient_design_session', 
  secure: true, 
  same_site: :none