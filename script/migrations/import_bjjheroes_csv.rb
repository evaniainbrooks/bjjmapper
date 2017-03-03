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

  opts.on("-s", "--simulate", "Simulate") do |v|
    options[:simulate] = true
  end
end.parse!

FIXUPS = {
  'L. Vieira' => 'Leonardo Vieira',
  'Carlos Gracie Junior' => 'Carlos Gracie Jr.',
  'Carlson Gracie Junior' => 'Carlson Gracie Jr.',
  'C. Gracie Junior' => 'Carlos Gracie Jr.',
  'Carlos G. Jr' => 'Carlos Gracie Jr.',
  'Carlos Gracie Sr.' => 'Carlos Gracie',
  'Carlos Gracie Jr' => 'Carlos Gracie Jr.',
  'Carlos Gracie Sr' => 'Carlos Gracie',
  'Carlos Gracie Senior' => 'Carlos Gracie',
  'R. Barral' => 'Romulo Barral',
  'Rubens Charles' => 'Rubens Charles Maciel',
  'L. Irvin' => 'Lloyd Irvin',
  'R. Lovato' => 'Rafael Lovato Jr.',
  'R. Lovato Jr' => 'Rafael Lovato Jr.',
  'Vinicius Magalhaes' => 'Vinny Magalhaes',
  'Helio G.' => 'Helio Gracie',
  'Helio G' => 'Helio Gracie',
  'Carlson G.' => 'Carlson Gracie',
  'Carlson G' => 'Carlson Gracie'
}.freeze

$users = User.where(:role.ne => 'anonymous').inject({}) do |hash, u|
  hash[I18n.transliterate(u.name)] = u
  hash
end

def find_or_create_user_simple(name, lineage_stack, simulate = false)
  name = FIXUPS[name] || name

  u = $users[name]
  u ||= User.new do |o|
    o.name = name
    o.belt_rank = 'black'
    o.stripe_rank = 0
    o.source = 'BJJHeroesStub'
    o.lineal_parent = find_or_create_user_simple(lineage_stack.last, lineage_stack[0...-1], simulate) if lineage_stack.present?
    o
  end
  puts "Searching for lineal parent #{name} found #{u.inspect}"

  unless simulate
    u.save
    $users[u.name] = u
  end
  u
end

def find_or_create_user(row, simulate = false)
  name = "#{row[0]} #{row[1]}"
  name = FIXUPS[name] || name

  u = $users[name]

  puts "Searching for #{name} found #{u.inspect}"
  if u.nil? || u.source != 'BJJHeroes'
    lineage = row[5].try(:split, ';').try(:last)

    u ||= User.new
    u.cover_image = row[7]
    u.name = name
    u.nickname = row[2]
    u.belt_rank = 'black'
    u.stripe_rank = 0
    u.lineal_parent = find_or_create_user_simple(lineage, simulate) if lineage.present?
    u.description = row[8]
    u.description_read_more_url = row[4]
    u.description_src = 'BJJHeroes'
    u.source = 'BJJHeroes'
    unless simulate
      u.save
      $users[name] = u
    end
  end

  u
end

f = File.open(options[:filename], "r")
csv = CSV.parse(f, :headers => true)
puts "Running as #{Rails.env}"
csv.each do |row|
  #first_name,last_name,nickname,team_name,url,lineage,biography,image_url,summary
  user = find_or_create_user(row, options[:simulate])
  puts "Got #{user.inspect}"
end

p options

p ARGV
