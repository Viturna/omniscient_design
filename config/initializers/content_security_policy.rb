Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, :blob # Ajout de :blob pour les prévisualisations d'images
    policy.object_src  :none

    # SCRIPTS : On garde les nonces pour la sécurité
    policy.script_src  :self, :https, "https://cdn.jsdelivr.net", "https://ga.jspm.io", :unsafe_inline

    # STYLES : On ajoute :unsafe_inline pour autoriser les attributs style="..."
    # C'est nécessaire car beaucoup de JS (GSAP, jQuery, etc.) modifient le style directement.
    policy.style_src   :self, :https, :unsafe_inline
  end

  # On garde le générateur de nonce pour les balises <script> et <style>
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src) # J'ai retiré style-src ici
end