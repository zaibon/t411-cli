module Utils
  HEADERS = ['#', 'ID', 'Name', 'Seeders']
  def choose_torrent(torrents)
    i = 0
    puts_torrents(torrents)
    print "Which torrent do you want ? (1-#{i}) : "
    index = STDIN.gets.chomp.to_i
    torrents[index-1]["id"]
  end

  def puts_torrents(torrents)
    rows = []
    i = 1
    torrents.each do |torrent|
      rows << [i, torrent['id'], format_name(torrent['name']), torrent['seeders']]
      i += 1
    end
    table = Terminal::Table.new :headings => HEADERS, :rows => rows
    table.align_column(3, :right)
    puts table
  end

  def upload_torrent(torrent)
    Net::SCP.start(@config[:autodownload_host], @config[:autodownload_username] ) do |scp|
      puts "#{torrent} ==> #{@config[:autodownload_path]}"
      scp.upload! torrent, @config[:autodownload_path]
    end
  end

  def format_name(str)
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
  
  def read_config
    YAML.load_file(File.join(File.expand_path('~'), '.t411'))
  end

  def create_config_file
    puts Rainbow("None configuration file found. Let's created it.").yellow
    config = {}
    config[:t411_user] = get_login
    config[:t411_pass] = get_password
    config[:betaserie_key] = get_api_key
    loop do
      if autodownload?
        config[:autodownload_host] = get_server_host
        config[:autodownload_username] = get_server_user
        config[:autodownload_path] = get_server_path
        config[:autodownload_enable] = true
        break
      else
        break
      end
    end
    write_config_file(config)
  end

  def write_config_file(data)
    print Rainbow("Writing config file...").blue
    data = data.to_yaml
    file = File.open(File.join(File.expand_path('~'), '.t411'), 'w')
    file.write(data)
    file.close
    puts Rainbow("[OK]\n\n").green
  end
end
