# db/seeds.rb
# Create Discos
mepco = Disco.create!(name: "MEPCO")
lesco = Disco.create!(name: "LESCO")
fesco = Disco.create!(name: "FESCO")

# Initialize a counter outside of your loops
meter_index = 1000

# Create Regions and nested divisions and subdivisions for MEPCO, LESCO, and FESCO
[["MEPCO", "M", mepco], ["LESCO", "L", lesco], ["FESCO", "F", fesco]].each do |disco_data|
  disco_name, prefix, disco = disco_data
  disco_regions = disco_name == "MEPCO" ? ["Multan", "Khanewal", "Vehari"] :
                  disco_name == "LESCO" ? ["Lahore", "Sheikhupura", "Qasur"] :
                  ["Faisalabad", "Jhang", "Toba Tek Singh"]

  disco_regions.each do |region_name|
    region = disco.regions.create!(name: region_name)
    division = region.divisions.create!(name: "#{region_name} Division")
    subdivision = division.subdivisions.create!(name: "#{region_name} Subdivision")

    # Create 20 meters for each subdivision
    20.times do |i|
      # Increment the meter_index for each new meter to ensure uniqueness
      meter_index += 1

      subdivision.meters.create!(
        NEW_METER_NUMBER: "#{prefix}#{region_name[0]}#{meter_index}",
        REF_NO: "REF#{meter_index}",
        METER_STATUS: ["Active", "Inactive", "Maintenance"].sample,
        OLD_METER_NUMBER: "OM#{meter_index}",
        OLD_METER_READING: rand(100..1000),
        NEW_METER_READING: rand(10..500),
        CONNECTION_TYPE: ["Residential", "Commercial", "Industrial"].sample,
        BILL_MONTH: Date.today - rand(1..12).months,
        LONGITUDE: rand(30..35).to_f,
        LATITUDE: rand(70..75).to_f,
        METER_TYPE: ["Analog", "Digital", "Smart"].sample,
        KWH_MF: rand(1.0..1.5).round(2),
        SAN_LOAD: rand(50..500).to_f,
        CONSUMER_NAME: "Customer #{meter_index}",
        CONSUMER_ADDRESS: "Street #{i}, City",
        QC_CHECK: [true, false].sample,
        APPLICATION_NO: "APP#{meter_index}",
        GREEN_METER: ["Yes", "No"].sample,
        TELCO: "Telecom Company",
        SIM_NO: "SIM#{meter_index}",
        SIGNAL_STRENGTH: ["Weak", "Moderate", "Strong"].sample,
        PICTURE_UPLOAD: "path/to/image",
        METR_REPLACE_DATE_TIME: DateTime.now,
        NO_OF_RESET_OLD_METER: rand(0..3),
        NO_OF_RESET_NEW_METER: rand(0..3),
        KWH_T1: rand(100..500).to_f,
        KWH_T2: rand(100..500).to_f,
        KWH_TOTAL: rand(200..1000).to_f,
        KVARH_T1: rand(25..125).to_f,
        KVARH_T2: rand(25..125).to_f,
        KVARH_TOTAL: rand(50..250).to_f,
        MDI_T1: rand(5..15).to_f,
        MDI_T2: rand(5..15).to_f,
        MDI_TOTAL: rand(10..30).to_f,
        CUMULATIVE_MDI_T1: rand(100..300).to_f,
        CUMULATIVE_MDI_T2: rand(100..300).to_f,
        CUMULATIVE_MDI_Total: rand(200..600).to_f
      )
    end
  end
end

# Calculate total number of meters
total_meters = Meter.count

# Calculate the distribution
meters_for_first_user = (total_meters * 0.60).round
meters_for_last_user = total_meters - meters_for_first_user  # This ensures there are no rounding issues

# Get the first and last user
first_user = User.first
last_user = User.last

# Update meters for the first user
Meter.limit(meters_for_first_user).update_all(user_id: first_user.id)

# Update meters for the last user
Meter.offset(meters_for_first_user).limit(meters_for_last_user).update_all(user_id: last_user.id)

