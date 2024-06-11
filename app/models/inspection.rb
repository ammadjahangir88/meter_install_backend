class Inspection < ApplicationRecord
  belongs_to :meter
  belongs_to :user

  validates :meter_type_ok, :display_verification_ok, :installation_location_ok, 
            :wiring_connection_ok, :sealing_ok, :documentation_ok, 
            :compliance_assurance_ok, inclusion: { in: [true, false] }

  # other validations and methods
end