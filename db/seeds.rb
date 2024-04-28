# db/seeds.rb
# Create Discos
mepco = Disco.create!(name: "MEPCO")
lesco = Disco.create!(name: "LESCO")
fesco = Disco.create!(name: "FESCO")

# Create Regions and nested divisions and subdivisions for MEPCO
mepco_regions = ["Multan", "Khanewal", "Vehari"]
mepco_regions.each do |region_name|
  region = mepco.regions.create!(name: region_name)
  division = region.divisions.create!(name: "#{region_name} Division")
  subdivision = division.subdivisions.create!(name: "#{region_name} Subdivision")
  base_ref_number = 1000
  # Create 20 meters for each subdivision

  base_ref_number += 100
end

# db/seeds.rb continued...

# Create Regions and nested divisions and subdivisions for LESCO
lesco_regions = ["Lahore", "Sheikhupura", "Qasur"]


# Create Regions and nested divisions and subdivisions for FESCO
fesco_regions = ["Faisalabad", "Jhang", "Toba Tek Singh"]
# Initialize the counter outside the regional loops
next_meter_number = 1000
next_ref_number = 2000

[lesco, mepco, fesco].each do |disco|
  disco.regions.each do |region_name|
    region = disco.regions.create!(name: region_name)
    division = region.divisions.create!(name: "#{region_name} Division")
    subdivision = division.subdivisions.create!(name: "#{region_name} Subdivision")

    20.times do |i|
      subdivision.meters.create!(
        NEW_METER_NUMBER: "#{region_name[0]}#{next_meter_number}",
        REF_NO: "REF#{next_ref_number}",
        METER_STATUS: ["Active", "Inactive", "Maintenance"].sample,
        OLD_METER_NUMBER: "OM#{1000 + i}",
        OLD_METER_READING: rand(100..1000),
        NEW_METER_READING: rand(10..500),
        CONNECTION_TYPE: ["Residential", "Commercial", "Industrial"].sample,
        BILL_MONTH: Date.today - rand(1..12).months,
        LONGITUDE: rand(30..35).to_f,
        LATITUDE: rand(70..75).to_f,
        METER_TYPE: ["Analog", "Digital", "Smart"].sample,
        KWH_MF: rand(1.0..1.5).round(2),
        SAN_LOAD: rand(50..500).to_f,
        CONSUMER_NAME: "Customer #{i}",
        CONSUMER_ADDRESS: "Street #{i}, City",
        QC_CHECK: [true, false].sample,
        APPLICATION_NO: "APP#{1000 + i}",
        GREEN_METER: ["Yes", "No"].sample,
        TELCO: ["Jazz", "Ufone", "Zong","Warid","Telenor"].sample,
        SIM_NO: "SIM#{1000 + i}",
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
      next_meter_number += 1
      next_ref_number += 1
    end
  end
end


# After setting up the seed file, run this script with `rails db:seed` to populate your database.

