locations = Location.where(:timezone => nil)
puts "Updating timezone for #{locations.count} locations"
locations.all.each do |loc|
  loc.save
  if loc.timezone.blank?
    puts "#{loc.title} timezone is still blank, exiting"
    exit
  end

  puts "#{loc.title} timezone is now #{loc.timezone}"
end if RollFindr::TimezoneService.timezone_for(80.0, 80.0).present?
