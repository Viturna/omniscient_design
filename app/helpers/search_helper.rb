module SearchHelper
  # Remplace aléatoirement certaines cartes par une publicité (pour conserver le même nombre total de cartes)
  def inject_search_ads(items, ads, frequency_range: 6..10, first_ad_range: 3..6)
    return items if ads.blank? || items.blank?

    result = []
    ad_index = rand(ads.length)
    items_until_next_ad = rand(first_ad_range)

    items.each do |item|
      items_until_next_ad -= 1

      if items_until_next_ad <= 0
        ad = ads[ad_index % ads.length]
        result << { _is_ad: true, ad: ad }
        ad_index += 1
        items_until_next_ad = rand(frequency_range)
      else
        result << item
      end
    end

    result
  end
end
