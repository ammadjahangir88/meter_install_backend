class CreateMeters < ActiveRecord::Migration[7.1]
  def change
    create_table :meters do |t|
      t.string :meter_no, null: false
      t.string :reference_no, null: false
      t.string :status
      t.string :old_meter_no
      t.float :old_meter_reading
      t.float :new_meter_reading
      t.string :connection_type
      t.date :bill_month
      t.float :longitude
      t.float :latitude
      t.string :meter_type
      t.float :kwh_mf
      t.float :sanction_load
      t.string :full_name
      t.text :address
      t.boolean :qc_check, default: false
      t.references :subdivision, foreign_key: true

      t.timestamps
    end
  end
end
