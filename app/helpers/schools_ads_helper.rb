module SchoolsAdsHelper
  def sa_on_subdomain?
    request.host.start_with?('schools-ads.') || request.subdomain.to_s.include?('schools-ads')
  end

  def sa_root_path
    sa_on_subdomain? ? '/' : '/schools-ads'
  end

  def sa_funnel_path
    sa_on_subdomain? ? '/creer-campagne' : '/schools-ads/creer-campagne'
  end

  def sa_dashboard_path
    sa_on_subdomain? ? '/dashboard' : '/schools-ads/dashboard'
  end

  def sa_success_path(params = {})
    query = params.any? ? "?#{params.to_query}" : ""
    (sa_on_subdomain? ? '/succes' : '/schools-ads/succes') + query
  end

  def sa_checkout_path
    sa_on_subdomain? ? '/checkout' : '/schools-ads/checkout'
  end

  def sa_contact_path
    sa_on_subdomain? ? '/contact' : '/schools-ads/contact'
  end

  def main_site_host
    request.host.sub(/\Aschools-ads\./, '')
  end

  def main_site_root_url
    port_suffix = (request.port && ![80, 443].include?(request.port)) ? ":#{request.port}" : ""
    "#{request.protocol}#{main_site_host}#{port_suffix}/"
  end

  def main_site_url(path = nil)
    return main_site_root_url if path.blank?
    port_suffix = (request.port && ![80, 443].include?(request.port)) ? ":#{request.port}" : ""
    clean_path = path.to_s.start_with?('/') ? path.to_s : "/#{path}"
    "#{request.protocol}#{main_site_host}#{port_suffix}#{clean_path}"
  end
end
