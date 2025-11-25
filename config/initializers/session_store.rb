Rails.application.config.session_store :cookie_store, 
  expire_after: 1.year,
  key: '_omniscient_design_session', 
  secure: Rails.env.production?,
  same_site: (Rails.env.production? ? :none : :lax)
  