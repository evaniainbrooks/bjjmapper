require 'optparse'
require 'csv'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: rails runner import_ibjjf_csv.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-f", "--filename", "Set filename") do |v|
    options[:filename] = ARGV.pop
  end
end.parse!

f = File.open(options[:filename], "r")
csv = CSV.parse(f, :headers => true)
puts "Running as #{Rails.env}"

org = Organization.where(:abbreviation => "IBJJF").first
if org.blank?
  puts "No IBJJF org found!"
  abort
else
  puts "IBJJF org is #{org.inspect}"
end

puts "Processing CSV file #{options[:filename]}"
csv.each do |row|
  title = row[0].strip.split.map(&:capitalize).join(' ')
  
  puts "Row is #{title}"
  date_start = row[1].strip
  date_start.slice!("Date: ")
  date_end = row[2].strip
  date_end.slice!("Date: " )
  reg_start = row[3].strip
  reg_start.slice!("Registration: ")
  reg_end = row[4].strip
  venue_name = row[5].strip
  venue_name.slice!("Location: ")
  venue_name = venue_name.split(',', 1)[0]
  venue_address = row[6].gsub(/Telephone Number: [^a-zA-Z]+/, '').gsub(/Homepage: [a-zA-Z.]+/, '').gsub('Federative Republic of', '').gsub('Republic of the', '').gsub('Republic of', '').gsub('Kingdom of', '')
  link = row[9].strip

  results = GeocodersHelper.search(venue_address)
  if results.blank?
    puts "*** Couldn't geocode #{venue_address}, skipping #{title}"
    next
  else
    puts "Got #{results.count} geocode results #{results.inspect}"
  end

  source = File.basename(__FILE__)
  venue = Location.where(:title => venue_name).first_or_create({
    loctype: Location::LOCATION_TYPE_EVENT_VENUE,
    street: results[0].street,
    #image: row[10] || row[11],
    city: results[0].city,
    postal_code: results[0].postal_code,
    country: results[0].country,
    state: results[0].state,
    coordinates: [results[0].lng, results[0].lat],
    source: source
  })

  puts "Venue is #{venue.to_param} errors #{venue.errors.messages}"

  su = User.where(:role => 'super_user').first
  Time.use_zone(venue.timezone) do
    event = Event.create({
      title: title,
      image: row[11],
      cover_image: row[10],
      event_type: Event::EVENT_TYPE_TOURNAMENT,
      organization: org,
      location: venue,
      modifier: su,
      is_all_day: true,
      starting: Time.parse(date_start).beginning_of_day,
      ending: (Time.parse(date_end) + 1.day).beginning_of_day,
      website: link,
      source: source
    })
    event_reg_start = Event.create({
      title: "Registration opens",
      event_type: Event::EVENT_TYPE_SUBEVENT,
      parent_event: event,
      organization: org,
      location: venue,
      modifier: su,
      is_all_day: true,
      starting: Time.parse(reg_start).beginning_of_day,
      ending: (Time.parse(reg_start) + 1.day).beginning_of_day,
      website: link,
      source: source
    })
    event_reg_end = Event.create({
      title: "Registration closes",
      event_type: Event::EVENT_TYPE_SUBEVENT,
      parent_event: event,
      organization: org,
      location: venue,
      modifier: su,
      is_all_day: true,
      starting: Time.parse(reg_end).beginning_of_day,
      ending: (Time.parse(reg_end) + 1.day).beginning_of_day,
      website: link,
      source: source
    })

    puts "Created event #{event.to_param} errors #{event.errors.messages}"
    puts "Created subevent #{event_reg_start.to_param} errors #{event_reg_start.errors.messages}"
    puts "Created subevent #{event_reg_end.to_param} errors #{event_reg_end.errors.messages}"
  end

  puts title
end

