Rails.application.configure do
  config.content_security_policy do |policy|
    # On autorise HTTP et HTTPS
    policy.default_src :self, :https, :http, :unsafe_inline
    policy.font_src    :self, :https, :data
    
    # IMAGES : On autorise explicitement localhost:9000 et le schéma http:
    policy.img_src     :self, :https, :http, :data, :blob, "http://localhost:9000"
    
    policy.object_src  :none
    
    # SCRIPTS : On autorise tout le monde pour débloquer la situation
    policy.script_src  :self, :https, :http, :unsafe_inline, :unsafe_eval, "https://cdn.jsdelivr.net", "https://ga.jspm.io"
    
    # STYLES : On autorise le style inline
    policy.style_src   :self, :https, :http, :unsafe_inline
  end

  # --- LA SOLUTION EST ICI ---
  # Ne commente pas cette ligne. Mets-la à NIL pour forcer la désactivation.
  config.content_security_policy_nonce_generator = nil
end