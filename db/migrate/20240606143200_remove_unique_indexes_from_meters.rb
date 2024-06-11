class RemoveUniqueIndexesFromMeters < ActiveRecord::Migration[7.1]
  def change
    remove_index :meters, :NEW_METER_NUMBER
  end
end
