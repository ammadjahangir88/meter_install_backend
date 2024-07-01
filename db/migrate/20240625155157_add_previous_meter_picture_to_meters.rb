class AddPreviousMeterPictureToMeters < ActiveRecord::Migration[7.1]
  def change
    add_column :meters, :PREVIOUS_METER_PICTURE, :string
  end
end
