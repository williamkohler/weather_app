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

  def self.get_forecast(latitude, longitude)
    url = URI("https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&hourly=temperature_2m&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_sum,precipitation_probability_max&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch")

    response = Net::HTTP.get_response(url)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      { error: "Failed to fetch forecast", status: response.code }
    end
  end

  def self.seven_day_forecast(address)
    data = []
    coordinates = get_coordinates(address)
    res = get_forecast(coordinates.first, coordinates.last)
    res = res["daily"]
    (0..6).each do |index|
      day = {}
      day[:max] = res["temperature_2m_max"][index]
      day[:min] = res["temperature_2m_min"][index]
      day[:sunrise] = res["sunrise"][index]
      day[:sunset] = res["sunset"][index]
      day[:precip_sum] = res["precipitation_sum"][index]
      day[:precip_sum] = res["precipitation_probability_max"][index]
      data << day
    end
    data
  end
end
