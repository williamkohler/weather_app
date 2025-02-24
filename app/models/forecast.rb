require "net/http"
require "uri"
require "json"

class Forecast < ApplicationRecord
  def self.get_coordinates(address)
    results = Geocoder.search(address)
    if results.any?
      results.first.coordinates # => [latitude, longitude]
    else
      [ nil, nil ]
    end
  end

  def self.get_forecast_from_api(latitude, longitude)
    url = URI("https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&hourly=temperature_2m&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_sum,precipitation_probability_max&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch")

    response = Net::HTTP.get_response(url)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      { error: "Failed to fetch forecast", status: response.code }
    end
  end


  # Fetches the seven-day forecast for a given address.
  # If cached data is less than 30 minutes old, return it; otherwise, fetch new data.
  def self.seven_day_forecast(address)
    address = address.strip # TODO: add normalization
    last_updated = last_cache_update(address)

    if last_updated.present? && last_updated > 30.minutes.ago
      puts "\ngetting from cache\n"
      # Cache is still valid, return cached data
      Rails.logger.info "Returning cached forecast data for #{address}"
      cached_forecast(address)
    else
      puts "\n getting from API\n"
      # Cache is expired or missing, fetch new data and store it
      Rails.logger.info "Fetching new forecast data for #{address}"
      fetch_and_cache_seven_day_forecast(address)
    end
  end

  def self.fetch_and_cache_seven_day_forecast(address)
    cache_key = "forecast:#{address.parameterize}"  # Cache key based on the address
    timestamp_key = "#{cache_key}:timestamp"

    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      coordinates = get_coordinates(address)
      res = get_forecast_from_api(coordinates.first, coordinates.last)

      data = []
      if res["daily"]
        (0..6).each do |index|
          day = {
            max: res["daily"]["temperature_2m_max"][index],
            min: res["daily"]["temperature_2m_min"][index],
            sunrise: res["daily"]["sunrise"][index],
            sunset: res["daily"]["sunset"][index],
            precip_sum: res["daily"]["precipitation_sum"][index],
            precip_prob: res["daily"]["precipitation_probability_max"][index]
          }
          data << day
        end
      end
       forecast = Forecast.find_or_initialize_by(address: address)
       forecast.update(data: data, updated_at: Time.current)
       Rails.cache.write(timestamp_key, Time.current, expires_in: 30.minutes)

      data
    end
  end

  def self.last_cache_update(address)
    where(address: address).order(updated_at: :desc).limit(1).pluck(:updated_at).first
  end

  def self.cached_forecast(address)
    forecast_data = where(address: address).order(updated_at: :desc).limit(1).pluck(:data).first
    forecast_data.present? ? eval(forecast_data) : nil
  end
end
