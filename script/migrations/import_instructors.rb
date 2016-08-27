require 'optparse'
require 'csv'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: rails runner import_csv.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-f", "--filename", "Set filename") do |v|
    options[:filename] = ARGV.pop
  end
end.parse!

f = File.open(options[:filename], "r")
csv = CSV.parse(f, :headers => false)
puts "Running as #{Rails.env}"
csv.each do |row|
  name = row[0].strip
  u = User.where(:name => name,  :role => :instructor).first_or_create(:belt_rank => row[1], :stripe_rank => row[2])
  puts "Created instructor #{u.name} #{u.belt_rank} #{u.stripe_rank} #{u.image}"
end

p options

p ARGV
