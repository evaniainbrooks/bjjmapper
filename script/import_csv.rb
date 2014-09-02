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
  p "Creating #{row[0]}"
  Location.create!({:title => row[0], :street => row[1], :city => row[2], :state => row[3], :postal_code => row[4], :country => row[5], :website => row[6], :phone => row[7], :head_instructor => User.where(:name => row[8]).first_or_create, :team => Team.where(:name => row[9]).first_or_create})
end

p options

p ARGV
