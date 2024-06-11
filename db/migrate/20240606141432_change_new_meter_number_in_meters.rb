class ChangeNewMeterNumberInMeters < ActiveRecord::Migration[7.1]
  def change
    change_column :meters, :NEW_METER_NUMBER, :string, null: true
  end
end
