module Utils
  def choose_torrent(torrents)
    i = 0
    torrents.sort!{|t1, t2| t2['seeders'].to_i <=> t1['seeders'].to_i}
    torrents.each do |torrent|
      i += 1
      str = "#{i}. #{torrent["id"]} - #{torrent["name"]} #{torrent["seeders"]}/#{torrent["leechers"]}"
      scans = str.scan(/VOSTFR|FASTSUB|VO|FRENCH/)
      scans.each do |scan|
        str.sub!(scan, Rainbow(scan).yellow.underline)
      end
      scans = str.scan(/HDTV|720p|1080p/)
      scans.each do |scan|
        str.sub!(scan, Rainbow(scan).blue.underline)
      end
      puts str
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
