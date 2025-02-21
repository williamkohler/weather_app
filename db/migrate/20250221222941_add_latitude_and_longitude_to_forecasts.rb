class AddLatitudeAndLongitudeToForecasts < ActiveRecord::Migration[8.0]
  def change
    add_column :forecasts, :latitude, :float
    add_column :forecasts, :longitude, :float
  end
end
