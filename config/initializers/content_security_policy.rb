Rails.application.configure do
  config.content_security_policy do |policy|
    # On autorise HTTP et HTTPS
    policy.default_src :self, :https, :http, :unsafe_inline
    policy.font_src    :self, :https, :data
    
    # IMAGES : On garde ta config
    policy.img_src     :self, :https, :http, :data, :blob, "http://localhost:9000"
    
    policy.object_src  :none
    
    # --- LA CORRECTION EST ICI ---
    # J'ai ajouté :blob à la liste ci-dessous
    policy.script_src  :self, :https, :http, :unsafe_inline, :unsafe_eval, :blob, "https://cdn.jsdelivr.net", "https://ga.jspm.io"
    
    # STYLES
    policy.style_src   :self, :https, :http, :unsafe_inline
  end

  # On s'assure que les Nonces sont désactivés
  config.content_security_policy_nonce_generator = nil
end