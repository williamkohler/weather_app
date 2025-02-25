require "net/http"
require "uri"
require "json"

class Forecast < ApplicationRecord
  validates :address, presence: true
  attr_accessor :from_api
  after_create :set_coordinates, :get_forecast_from_api

  def set_coordinates
    results = Geocoder.search address
    if results.any?
      self.latitude = results.first.data["lat"]
      self.longitude = results.first.data["lon"]
      save!
    end
  end

  def get_forecast_from_api
    url = URI("https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&hourly=temperature_2m&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_sum,precipitation_probability_max&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch")

    response = Net::HTTP.get_response(url)

    if response.is_a?(Net::HTTPSuccess)
      @from_api = true
      JSON.parse(response.body)
    else
      { error: "Failed to fetch forecast", status: response.code }
    end
  end


  # Fetches the seven-day forecast for a given address.
  # If cached data is less than 30 minutes old, return it; otherwise, fetch new data.
  def seven_day_forecast
    if cached?
      Rails.logger.info "Returning cached forecast data for #{address}"
      @from_api = false
      cached_forecast
    else
      Rails.logger.info "Fetching new forecast data for #{address}"
      @from_api = true
      fetch_and_cache_forecast
    end
  end

  def fetch_and_cache_forecast
    timestamp_key = "#{cache_key}:timestamp"

    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      res = get_forecast_from_api

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

  def last_cache_update
    self.class.where(address: address).order(updated_at: :desc).limit(1).pluck(:updated_at).first
  end

  def cached_forecast
    Rails.cache.fetch(cache_key)
  end

  def cached?
    Rails.cache.exist?(cache_key)
  end

  def cache_key
    "forecast:#{address.parameterize}"
  end
end
