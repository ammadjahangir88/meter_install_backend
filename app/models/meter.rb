class Meter < ApplicationRecord
    belongs_to :subdivision, optional: true
  
    # Defining custom getter methods for attributes stored in uppercase or unconventional formats in the database
    def application_no
      self[:APPLICATION_NO]  # Correctly access the attribute
    end
  
    def green_meter
      self[:GREEN_METER]
    end
  
    def telco
      self[:TELCO]
    end
  
    def sim_no
      self[:SIM_NO]
    end
  
    def signal_strength
      self[:SIGNAL_STRENGTH]
    end
    def new_meter_number
        self[:NEW_METER_NUMBER]
     
    end  
    def picture_upload
        self[:PICTURE_UPLOAD]
    end    
  
    def self.csv_headers
      ["ID", "Application No", "Reference No", "Status", "Green Meter", "Telco", "SIM No", "Signal Strength", "New Meter Number", "Old Meter Number", "New Meter Reading", "Connection Type", "Bill Month", "Meter Type", "Kwh MF", "Sanction Load", "Full Name", "Address", "Picture Upload", "Longitude", "Latitude"]
    end
  
    def csv_attributes
      [id, application_no, reference_no, status, green_meter, telco, sim_no, signal_strength, new_meter_number, old_meter_no, new_meter_reading, connection_type, bill_month, meter_type, kwh_mf, sanction_load, full_name, address, picture_upload, longitude, latitude]
    end
  
    def self.to_csv
      CSV.generate(headers: true) do |csv|
        csv << csv_headers
        all.each do |meter|
          csv << meter.csv_attributes
        end
      end
    end
end
  
  
  