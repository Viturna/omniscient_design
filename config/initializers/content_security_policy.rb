Rails.application.configure do
  config.content_security_policy do |policy|
    # Autorise HTTP (dev), HTTPS, et unsafe_inline (styles/scripts)
    policy.default_src :self, :https, :http, :unsafe_inline
    policy.font_src    :self, :https, :data
    
    # Autorise les images locales (port 9000) et les blobs
    policy.img_src     :self, :https, :http, :data, :blob, "http://localhost:9000"
    
    policy.object_src  :none
    
    # SCRIPTS : LA LIGNE CRITIQUE
    # On autorise :blob pour es-module-shims
    # On autorise unsafe_eval pour certaines libs JS complexes
    policy.script_src  :self, :https, :http, :unsafe_inline, :unsafe_eval, :blob, "https://cdn.jsdelivr.net", "https://ga.jspm.io"
    
    # Styles : On autorise le style inline (attributs style="...")
    policy.style_src   :self, :https, :http, :unsafe_inline
  end

  # IMPORTANT : On désactive le nonce generator pour éviter les conflits avec unsafe-inline
  config.content_security_policy_nonce_generator = nil
end