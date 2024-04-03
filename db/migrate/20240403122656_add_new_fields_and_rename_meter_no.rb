class AddNewFieldsAndRenameMeterNo < ActiveRecord::Migration[7.1]
  def change
    add_column :meters, :APPLICATION_NO, :string
    add_column :meters, :GREEN_METER, :string
    rename_column :meters, :meter_no, :NEW_METER_NUMBER
    add_column :meters, :TELCO, :string
    add_column :meters, :SIM_NO, :string
    add_column :meters, :SIGNAL_STRENGTH, :string
    add_column :meters, :PICTURE_UPLOAD, :string
  end
end
