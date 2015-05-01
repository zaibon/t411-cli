module T411
  require 'net/scp'

  def read_config
    YAML.load_file(File.join(File.expand_path('~'), '.t411'))
  end

  def episodes_list(args)
    title = args[0]
    season = args[1]
    episode = args[2]

    show_id = show_id(title)

    # Then I can call the API to get the episodes list
    uri = "https://api.betaseries.com/shows/episodes?id=#{show_id}"
    uri += "&season=#{season}" unless season.nil?
    uri += "&episode=#{episode}" unless episode.nil?
    uri = URI.encode(uri)
    response = HTTParty.get(uri, {headers: {'X-BetaSeries-Version' => '2.4', 'X-BetaSeries-Key' => @config[:betaserie_key]}})
    response = JSON.parse(response.body)
    episodes = []
    response["episodes"].each do |ep|
      episodes << ep['code']
    end

    episodes
  end

  def show_id(title)
    uri = URI.encode("https://api.betaseries.com/shows/search?title=#{title}&summary=true&order=popularity&nbpp=1")
    response = HTTParty.get(uri, {headers: {'X-BetaSeries-Version' => '2.4', 'X-BetaSeries-Key' => @config[:betaserie_key]}})
    response = JSON.parse(response.body)
    response["shows"].first["id"]
  end

  def auth_t411
    response = HTTParty.post('https://api.t411.io/auth', {body: {username: @config[:t411_user], password: @config[:t411_pass]}})
    response =  JSON.parse(response.body)
    response['token']
  end

  def download_t411(args)
    title = args[0]
    episodes_list = args[1]
    torrents_file = []
    episodes_list.each do |ep|
      torrents = search_t411(title, ep)
      torrent_id = choose_torrent(torrents)
      response = HTTParty.get("https://api.t411.io/torrents/download/#{torrent_id}", {headers: {'Authorization' => @config[:t411_token]}})
      path = File.join(File.expand_path('~'), 'Downloads', "#{title}-#{ep}.torrent")
      file = File.open(path, 'w')
      file.write(response)
      file.close
      torrents_file << path
    end
    torrents_file
  end

  def search_t411(title, ep)
    uri = URI.encode("https://api.t411.io/torrents/search/#{title} #{ep}")
    response = HTTParty.get(uri, {headers: {'Authorization' => @config[:t411_token]}})
    JSON.parse(response.body)["torrents"]
  end

  def choose_torrent(torrents)
    i = 0
    torrents.each do |torrent|
      i += 1
      puts "#{i}. #{torrent["id"]} - #{torrent["name"]} #{torrent["seeders"]}/#{torrent["leechers"]}"
    end
    print "Which torrent do you want ? (1-#{i}) : "
    index = STDIN.gets.chomp.to_i
    torrents[index-1]["id"]
  end

  def upload_torrent(torrents)
    Net::SCP.start(@config[:autodownload_host], @config[:autodownload_username] ) do |scp|
      torrents.each do |torrent|
        puts "#{torrent} ==> #{@config[:autodownload_path]}"
        scp.upload! torrent, @config[:autodownload_path]
      end
    end
  end
end