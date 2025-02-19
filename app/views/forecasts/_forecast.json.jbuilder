json.extract! forecast, :id, :address, :created_at, :updated_at
json.url forecast_url(forecast, format: :json)
