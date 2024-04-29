class AddUserIdForeignKeyToMeters < ActiveRecord::Migration[7.1]
  def change
    add_reference :meters, :user, null: true, foreign_key: true
  end
end


Meter.all.each  do |meter|
  user=User.first
  meter.user=user
end


