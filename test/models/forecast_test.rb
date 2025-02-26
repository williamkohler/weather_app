require "test_helper"

class ForecastTest < ActiveSupport::TestCase
  def setup
    @forecast = Forecast.new(address: "Boston, MA")
  end

  test "valid forecast must have address" do
    @forecast.address = nil
    assert_not @forecast.valid?, "Forecast must have an address"
  end

  test "set_coordinates sets latitude and longitude" do
    Geocoder.stub :search, [ OpenStruct.new(data: { "lat" => 42.3601, "lon" => -71.0589 }, display_name: "Boston, MA") ] do
      @forecast.set_coordinates
      assert_equal 42.3601, @forecast.latitude
      assert_equal -71.0589, @forecast.longitude
      assert_equal "Boston, MA", @forecast.address
    end
  end

  test "get_forecast_from_api fetches data successfully" do
    fake_response = Net::HTTPSuccess.new(1.0, "200", "OK")
    fake_response.stub :body, '{"daily": {"temperature_2m_max": [70, 68, 69], "temperature_2m_min": [50, 49, 48], "sunrise": ["06:00", "06:01", "06:02"], "sunset": ["18:00", "18:01", "18:02"], "precipitation_sum": [0.1, 0.0, 0.2], "precipitation_probability_max": [10, 20, 30]}}'

    Net::HTTP.stub :get_response, fake_response do
      data = @forecast.get_forecast_from_api
      assert data.is_a?(Hash), "API should return a Hash"
      assert_equal 70, data["daily"]["temperature_2m_max"].first
    end
  end

  test "seven_day_forecast uses cached data if available" do
    Rails.cache.write(@forecast.cache_key, "Cached forecast data", expires_in: 30.minutes)
    Rails.cache.write("#{@forecast.cache_key}:timestamp", Time.current, expires_in: 30.minutes)
    @forecast.stub :cached?, true do
      assert_equal "Cached forecast data", @forecast.seven_day_forecast
    end
  end

  test "seven_day_forecast fetches new data if cache is expired" do
    @forecast.stub :cached?, false do
      @forecast.stub :fetch_and_cache_forecast, "New forecast data" do
        assert_equal "New forecast data", @forecast.seven_day_forecast
      end
    end
  end
end
