class CreateInspections < ActiveRecord::Migration[6.1]
  def change
    create_table :inspections do |t|
      t.references :meter, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :meter_type_ok
      t.boolean :display_verification_ok
      t.boolean :installation_location_ok
      t.boolean :wiring_connection_ok
      t.boolean :sealing_ok
      t.boolean :documentation_ok
      t.boolean :compliance_assurance_ok
      t.text :remarks

      t.timestamps
    end

    remove_column :meters, :QC_CHECK, :boolean, default: false
  end
end
