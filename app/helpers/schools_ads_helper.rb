module SchoolsAdsHelper
  def sa_on_subdomain?
    request.subdomain.to_s.include?('schools-ads')
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
end
