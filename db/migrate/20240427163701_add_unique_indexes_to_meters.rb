class AddUniqueIndexesToMeters < ActiveRecord::Migration[7.1]
  def change
    add_index :meters, :NEW_METER_NUMBER, unique: true
    add_index :meters, :REF_NO, unique: true
  end
end
