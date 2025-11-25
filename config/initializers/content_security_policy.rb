Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https, :http, :unsafe_inline
    
    # FONTS : On autorise data: et le domaine actuel
    policy.font_src    :self, :https, :http, :data
    
    policy.img_src     :self, :https, :http, :data, :blob, "http://localhost:9000"
    policy.object_src  :none
    
    # SCRIPTS : On garde :blob et unsafe_eval/inline
    policy.script_src  :self, :https, :http, :unsafe_inline, :unsafe_eval, :blob, "https://cdn.jsdelivr.net", "https://ga.jspm.io"
    
    policy.style_src   :self, :https, :http, :unsafe_inline
  end

  config.content_security_policy_nonce_generator = nil
end