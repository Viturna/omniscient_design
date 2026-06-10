require 'iso_country_codes'

module CountriesHelper
  def country_flag(country_numeric)
    country_code = begin
      IsoCountryCodes.find(country_numeric.to_s).alpha2
    rescue StandardError
      nil
    end
    return country_numeric.to_s unless country_code

    offset = 127_397
    country_code.upcase.chars.map { |char| (char.ord + offset).chr(Encoding::UTF_8) }.join
  end
end
