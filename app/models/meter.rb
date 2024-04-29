class Meter < ApplicationRecord
  belongs_to :subdivision
  belongs_to :user, optional: true
  has_one_attached :image
  validates :NEW_METER_NUMBER, :REF_NO, presence: true
  validates :NEW_METER_NUMBER, presence: true, uniqueness: true
  validates :REF_NO, presence: true, uniqueness: true
  # Define CSV headers
  def self.csv_headers
    [
      "ID", "APPLICATION_NO", "REF_NO", "METER_STATUS", "GREEN_METER", "NEW_METER_NUMBER",
      "OLD_METER_NUMBER", "MAKE_AND_MANUFACTURING_YEAR", "METR_REPLACE_DATE_TIME", 
      "NO_OF_RESET_OLD_METER", "NO_OF_RESET_NEW_METER", "KWH_T1", "KWH_T2", "KWH_TOTAL",
      "KVARH_T1", "KVARH_T2", "KVARH_TOTAL", "MDI_T1", "MDI_T2", "MDI_TOTAL",
      "CUMULATIVE_MDI_T1", "CUMULATIVE_MDI_T2", "CUMULATIVE_MDI_TOTAL",
      "LONGITUDE", "LATITUDE", "NEW_METER_READING", "OLD_METER_READING",
      "CONNECTION_TYPE", "SAN_LOAD", "BILL_MONTH", "METER_TYPE", "KWH_MF", "TELCO", "SIM_NO",
      "SIGNAL_STRENGTH", "CONSUMER_NAME", "CONSUMER_ADDRESS", "PICTURE_UPLOAD"
    ]
  end

  # Returns an array of attribute values in the order of csv_headers
  def csv_attributes
    [
      id, application_no, ref_no, meter_status, green_meter, new_meter_number,
      old_meter_number, make_and_manufacturing_year, metr_replace_date_time,
      no_of_reset_old_meter, no_of_reset_new_meter, kwh_t1, kwh_t2, kwh_total,
      kvarh_t1, kvarh_t2, kvarh_total, mdi_t1, mdi_t2, mdi_total,
      cumulative_mdi_t1, cumulative_mdi_t2, cumulative_mdi_total,
      longitude, latitude, new_meter_reading, old_meter_reading,
      connection_type, san_load, formatted_bill_month, meter_type, kwh_mf, telco, sim_no,
      signal_strength, consumer_name, consumer_address, picture_upload
    ]
  end

  # Define helper methods for each attribute
  def application_no
    self[:APPLICATION_NO]
  end  

  def ref_no
    self[:REF_NO]
  end

  def meter_status
    self[:METER_STATUS]
  end

  def green_meter
    self[:GREEN_METER]
  end

  def new_meter_number
    self[:NEW_METER_NUMBER]
  end

  def old_meter_number
    self[:OLD_METER_NUMBER]
  end

  def make_and_manufacturing_year
    self[:MAKE_AND_MANUFACTURING_YEAR]
  end

  def metr_replace_date_time
    self[:METR_REPLACE_DATE_TIME]
  end

  def no_of_reset_old_meter
    self[:NO_OF_RESET_OLD_METER]
  end

  def no_of_reset_new_meter
    self[:NO_OF_RESET_NEW_METER]
  end

  def kwh_t1
    self[:KWH_T1]
  end

  def kwh_t2
    self[:KWH_T2]
  end

  def kwh_total
    self[:KWH_TOTAL]
  end

  def kvarh_t1
    self[:KVARH_T1]
  end

  def kvarh_t2
    self[:KVARH_T2]
  end

  def kvarh_total
    self[:KVARH_TOTAL]
  end

  def mdi_t1
    self[:MDI_T1]
  end

  def mdi_t2
    self[:MDI_T2]
  end

  def mdi_total
    self[:MDI_TOTAL]
  end

  def cumulative_mdi_t1
    self[:CUMULATIVE_MDI_T1]
  end

  def cumulative_mdi_t2
    self[:CUMULATIVE_MDI_T2]
  end

  def cumulative_mdi_total
    self[:CUMULATIVE_MDI_TOTAL]
  end

  def longitude
    self[:LONGITUDE]
  end

  def latitude
    self[:LATITUDE]
  end

  def new_meter_reading
    self[:NEW_METER_READING]
  end

  def old_meter_reading
    self[:OLD_METER_READING]
  end

  def connection_type
    self[:CONNECTION_TYPE]
  end

  def san_load
    self[:SAN_LOAD]
  end

  def formatted_bill_month
    self[:BILL_MONTH]&.strftime('%Y-%m-%d')
  end

  def meter_type
    self[:METER_TYPE]
  end

  def kwh_mf
    self[:KWH_MF]
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

  def consumer_name
    self[:CONSUMER_NAME]
  end

  def consumer_address
    self[:CONSUMER_ADDRESS]
  end

  def picture_upload
    self[:PICTURE_UPLOAD]
  end
end
