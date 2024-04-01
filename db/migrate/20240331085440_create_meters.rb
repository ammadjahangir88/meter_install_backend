class CreateMeters < ActiveRecord::Migration[7.1]
  def change
    create_table :meters do |t|
      add_column :meters, :meter_no, :string, null: false
      add_column :meters, :reference_no, :string, null: false
      add_column :meters, :status, :string
      add_column :meters, :old_meter_no, :string
      add_column :meters, :old_meter_reading, :float
      add_column :meters, :new_meter_reading, :float
      add_column :meters, :connection_type, :string
      add_column :meters, :bill_month, :date
      add_column :meters, :longitude, :float
      add_column :meters, :latitude, :float
      add_column :meters, :meter_type, :string
      add_column :meters, :kwh_mf, :float
      add_column :meters, :sanction_load, :float
      add_column :meters, :full_name, :string
      add_column :meters, :address, :text
      add_column :meters, :qc_check, :boolean, default: false
      add_reference :meters, :subdivision, foreign_key: true

      t.timestamps
    end
  end
end
