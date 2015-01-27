#app/views/sitemaps/index.xml.builder
base_url = "http://bjjmapper.com"
xml.instruct! :xml, :version=>'1.0'
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.url{
      xml.loc("http://bjjmapper.com")
      xml.changefreq("daily")
      xml.priority(1.0)
  }
  xml.url{
      xml.loc("http://bjjmapper.com/locations")
      xml.changefreq("daily")
      xml.priority(0.9)
  }
  xml.url{
      xml.loc("http://bjjmapper.com/meta")
      xml.changefreq("daily")
      xml.priority(0.9)
  }
  locations.each do |loc|
    xml.url {
      xml.loc "#{location_url(loc)}"
      xml.lastmod (loc.updated_at || loc.created_at).strftime("%F")
      xml.changefreq("weekly")
      xml.priority(0.8)
    }
  end
  teams.each do |team|
    xml.url {
      xml.loc "#{team_url(team)}"
      xml.lastmod (team.updated_at || team.created_at).strftime("%F")
      xml.changefreq("weekly")
      xml.priority(0.8)
    }
  end
  users.each do |user|
    xml.url {
      xml.loc "#{user_url(user)}"
      xml.lastmod (user.updated_at || user.created_at).strftime("%F")
      xml.changefreq("weekly")
      xml.priority(0.7)
    }
  end
end
