Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https, :http, :unsafe_inline
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :http, :data, :blob, "http://localhost:9000"
    policy.object_src  :none
    
    # On autorise tout pour être sûr que le Shim et les maps chargent
    policy.script_src  :self, :https, :http, :unsafe_inline, :unsafe_eval, :blob, "https://cdn.jsdelivr.net", "https://ga.jspm.io"
    
    policy.style_src   :self, :https, :http, :unsafe_inline
  end

  # Désactivation des Nonces pour éviter les blocages "Mappages non autorisés"
  config.content_security_policy_nonce_generator = nil
end