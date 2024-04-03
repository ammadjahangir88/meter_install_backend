class CreateSubdivisions < ActiveRecord::Migration[7.1]
  def change
    create_table :subdivisions do |t|
      t.string :name, null: false
      t.references :division, foreign_key: true
      t.timestamps
    end
  end
end
