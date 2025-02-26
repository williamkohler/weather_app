# README

# Weather Forecast App

## Description

The Weather Forecast App is a Rails application that allows users to enter an address to retrieve and display a seven-day weather forecast. The app uses the Geocoder gem to convert addresses into geographic coordinates and a weather API to fetch forecast data based on these coordinates.

## Features

- Address-based weather search
- Display of daily weather forecast including temperature highs and lows, sunrise and sunset times, and precipitation probabilities
- Caching of forecast data to reduce API calls and improve response times

## System Requirements

- **Ruby Version**: Ruby 3.0.0 or higher
- **Rails Version**: Rails 6.0.0 or higher
- **System Dependencies**:
  - PostgreSQL: For database management
  - Redis: For caching weather data
  - Sidekiq: For background job processing

## Configuration

1. **Clone the repository:**
   ```bash
   git clone https://yourrepository.com/weather_forecast_app.git
   cd weather_forecast_app
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Setup environment variables:**
   - `WEATHER_API_KEY`: Key for accessing the weather API.

## Database Creation and Initialization

- **Create the database:**
  ```bash
  rails db:create
  ```

- **Run migrations:**
  ```bash
  rails db:migrate
  ```

- **Seed the database (if applicable):**
  ```bash
  rails db:seed
  ```

## How to Run the Test Suite

Run the following command to execute the tests:

```bash
rails test
```

## Services

- **Job Queues**: Sidekiq is used for processing background jobs such as asynchronous API calls to fetch weather data.
- **Cache Servers**: Redis is utilized as a cache server to store the weather data temporarily and reduce the load on the weather API.
- **Search Engines**: Not applicable unless integrated for address searching capabilities.

## Deployment Instructions

1. **Set up Heroku**:
   - Create a Heroku account and log in.
   - Install the Heroku CLI and log in through the CLI.

2. **Create a new Heroku app**:
   ```bash
   heroku create
   ```

3. **Add buildpacks**:
   ```bash
   heroku buildpacks:set heroku/ruby
   heroku buildpacks:add --index 1 heroku/nodejs
   ```

4. **Configure environment variables on Heroku**:
   ```bash
   heroku config:set WEATHER_API_KEY="your_api_key_here"
   ```

5. **Deploy the application**:
   ```bash
   git push heroku master
   ```

6. **Run migrations on Heroku**:
   ```bash
   heroku run rails db:migrate
   ```

7. **Monitor logs**:
   ```bash
   heroku logs --tail
   ```

## Additional Information

For additional help or feedback, you can contact Bill Kohler .
bkohler4 [at] gmail [dot] com