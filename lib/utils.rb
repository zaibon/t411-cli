module Utils
  def choose_torrent(torrents)
    i = 0
    torrents = sort_by_seeder(torrents)
    torrents.each do |torrent|
      i += 1
      str = "#{i}. #{torrent["id"]} - #{torrent["name"]} #{torrent["seeders"]}/#{torrent["leechers"]}"
      str = format_string(str)
      puts str
    end
    print "Which torrent do you want ? (1-#{i}) : "
    index = STDIN.gets.chomp.to_i
    torrents[index-1]["id"]
  end

  def upload_torrent(torrent)
    Net::SCP.start(@config[:autodownload_host], @config[:autodownload_username] ) do |scp|
      puts "#{torrent} ==> #{@config[:autodownload_path]}"
      scp.upload! torrent, @config[:autodownload_path]
    end
  end

  def format_string(str)
    scans = str.scan(/VOSTFR|FASTSUB|VO|FRENCH/)
    scans.each do |scan|
      str.sub!(scan, Rainbow(scan).yellow.underline)
    end
    scans = str.scan(/HDTV|720p|1080p/)
    scans.each do |scan|
      str.sub!(scan, Rainbow(scan).blue.underline)
    end
    str
  end

  def sort_by_seeder(torrents)
    torrents.sort{|t1, t2| t2['seeders'].to_i <=> t1['seeders'].to_i}
  end

  def get_login
    print Rainbow('T411 login : ').blue
    login = STDIN.gets.chomp
    login
  end

  def get_password
    require 'io/console'
    print Rainbow('T411 password : ').blue
    password = STDIN.noecho(&:gets).chomp
    puts ""
    password
  end

  def get_api_key
    print Rainbow('Betaserie API key : ').blue
    key = STDIN.gets.chomp
    key
  end

  def autodownload?
    print Rainbow('enable auto upload torrent to a remote server ? (y/n) : ').blue
    res = STDIN.gets.chomp
    res.downcase == "y"
  end

  def get_server_host
    print Rainbow('server host : ').blue
    autodownload_host = STDIN.gets.chomp
    autodownload_host
  end

  def get_server_user
    print Rainbow('server username : ').blue
    autodownload_username = STDIN.gets.chomp
    autodownload_username
  end

  def get_server_path
    print Rainbow('server folder : ').blue
    autodownload_path = STDIN.gets.chomp
    autodownload_path
  end


  def write_config_file(data)
    print Rainbow("Writing config file...").blue
    data = data.to_yaml
    file = File.open(File.join(File.expand_path('~'), '.t411'), 'w')
    file.write(data)
    file.close
    puts Rainbow("[OK]").green
  end
end
