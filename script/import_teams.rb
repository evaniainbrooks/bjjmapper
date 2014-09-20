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
csv.each do |row|
  team_name = row[0].strip
  team = Team.where(:name => team_name).first_or_create(:image => row[1], :description => row[2])
end

p options

p ARGV
