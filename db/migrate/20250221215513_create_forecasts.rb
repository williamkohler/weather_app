class CreateForecasts < ActiveRecord::Migration[8.0]
  def change
    create_table :forecasts do |t|
      t.string :address
      t.string :data

      t.timestamps
    end
  end
end
