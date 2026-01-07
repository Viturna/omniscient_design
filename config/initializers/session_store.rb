Rails.application.config.session_store :cookie_store, 
  key: '_omniscient_design_session',
  expire_after: 1.year
  secure: true,
  same_site: :none