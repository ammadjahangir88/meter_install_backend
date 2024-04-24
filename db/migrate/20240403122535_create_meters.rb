class CreateMeters < ActiveRecord::Migration[7.1]
  def change
    create_table :meters, charset: 'utf8mb4', collation: 'utf8mb4_0900_ai_ci', force: :cascade do |t|
      t.string :NEW_METER_NUMBER, null: false
      t.string :REF_NO, null: false
      t.string :METER_STATUS
      t.string :OLD_METER_NUMBER
      t.float :OLD_METER_READING
      t.float :NEW_METER_READING
      t.string :CONNECTION_TYPE
      t.date :BILL_MONTH
      t.float :LONGITUDE
      t.float :LATITUDE
      t.string :METER_TYPE
      t.float :KWH_MF
      t.float :SAN_LOAD
      t.string :CONSUMER_NAME
      t.text :CONSUMER_ADDRESS
      t.boolean :QC_CHECK, default: false
      t.string :APPLICATION_NO
      t.string :GREEN_METER
      t.string :TELCO
      t.string :SIM_NO
      t.string :SIGNAL_STRENGTH
      t.string :PICTURE_UPLOAD
      t.datetime :METR_REPLACE_DATE_TIME
      t.integer :NO_OF_RESET_OLD_METER
      t.integer :NO_OF_RESET_NEW_METER
      t.float :KWH_T1
      t.float :KWH_T2
      t.float :KWH_TOTAL
      t.float :KVARH_T1
      t.float :KVARH_T2
      t.float :KVARH_TOTAL
      t.float :MDI_T1
      t.float :MDI_T2
      t.float :MDI_TOTAL
      t.float :CUMULATIVE_MDI_T1
      t.float :CUMULATIVE_MDI_T2
      t.float :CUMULATIVE_MDI_Total

      t.references :subdivision, index: true, foreign_key: true
      t.timestamps
    end
  end
end

