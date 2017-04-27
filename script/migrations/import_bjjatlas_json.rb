
require 'optparse'
require 'json'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: rails runner import_bjjatlas_json.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-s", "--simulate", "Don't create anything") do |v|
    options[:simulate] = true
  end

  opts.on("-f", "--filename", "Set filename") do |v|
    options[:filename] = ARGV.pop
  end
end.parse!

f = File.open(options[:filename], "r")
tournaments = JSON.parse(f.read)
puts"Running as #{Rails.env}, simulating: #{options[:simulating]}"

image_prefix = "https://storage.googleapis.com/bjjmapper/uploads/production/organizations/"

venue_created_count = 0
organization_created_count = 0
skipped_event_count = 0
 
su = User.where(:role => 'super_user').first

tournaments.each do |tournament|
  pp tournament if options[:verbose]
  
  source = File.basename(__FILE__)
  coordinates = [tournament['lat'], tournament['lng']].reverse
  venue_name = tournament['address']
  event_name = tournament['name']

  starting = tournament['startdate']
  ending = tournament['enddate']
  website = tournament['website']
  
  address = { 
    :street => tournament['addresstwo'],
    :country => tournament['country'],
    :postal_code => tournament['zip'],
    :city => tournament['city'],
    :state => tournament['state']
  }

  o = tournament['org']
  image = image_prefix + o['icon'].gsub('_icon', '')
  image_large = image.gsub('.png', '-large.png')
  image_tiny = image.gsub('.png', '-small.png')

  o = Organization.where(:abbreviation => o['abbrev']).first_or_initialize(
    :image => image,
    :image_large => image_large,
    :image_tiny => image_tiny,
    :name => o['name'],
    :website => o['website']
  )

  if o.new_record?
    o.save! unless options[:simulate]
    organization_created_count = organization_created_count + 1
    puts "Created organization #{o.name}"
  end

  puts "Organization is #{o.inspect}" if options[:verbose]
  puts "Event is #{event_name} at #{address.inspect}"

  nearby_venues = Location.geo_near(coordinates).max_distance(0.05).to_a.select{|x| x.loctype == Location::LOCATION_TYPE_EVENT_VENUE}
  puts "Found #{nearby_venues.count} nearby venues"

  venue = nearby_venues[0]
  unless venue.present?
    create_params = { 
      title: venue_name,
      coordinates: coordinates,
      source: source, 
      modifier: su,
      loctype: Location::LOCATION_TYPE_EVENT_VENUE 
    }.merge(iaddress)

    venue = Location.new(create_params)
    venue.save! unless options[:simulate]
    puts "Created venue #{venue.title}"
    
    venue_created_count = venue_created_count + 1
  end

  puts "Using #{venue.title} as the venue"
  existing_events = venue.events.tournaments.between_time(Time.parse(starting) - 5.days, Time.parse(ending) + 5.days).to_a
  if existing_events.present?
    puts "Skipping #{event_name} because it probably already exists (#{existing_events.inspect})"
    skipped_event_count = skipped_event_count + 1
    next
  end

  # Create the event
  Time.use_zone(venue.timezone) do
    event = Event.new({
      title: event_name,
      event_type: Event::EVENT_TYPE_TOURNAMENT,
      organization: o,
      location: venue,
      modifier: su,
      starting: Time.parse(starting).beginning_of_day,
      ending: (Time.parse(ending) + 1.day).beginning_of_day,
      website: website,
      source: source,
      is_all_day: true
    })

    event.save! unless options[:simulate]
    puts "Created event #{event_name}"
  end
end

puts "Finished. 
Created #{venue_created_count} venues
Created #{organization_created_count} organizations
Skipped #{skipped_event_count} events
Created #{tournaments.count - skipped_event_count} events"
