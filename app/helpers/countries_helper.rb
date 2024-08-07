require 'iso_country_codes'

module CountriesHelper
  def country_flag(country_numeric)
    country_code = IsoCountryCodes.find(country_numeric.to_s).alpha2 rescue nil
    return country_numeric.to_s unless country_code

    offset = 127397
    flag = country_code.upcase.chars.map { |char| (char.ord + offset).chr(Encoding::UTF_8) }.join
    flag
  end
end
