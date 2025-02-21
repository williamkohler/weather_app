class AddDataToForecasts < ActiveRecord::Migration[8.0]
  def change
    add_column :forecasts, :data, :text
  end
end
