module Utils
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
