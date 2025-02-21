json.extract! forecast, :id, :address, :data, :created_at, :updated_at
json.url forecast_url(forecast, format: :json)
