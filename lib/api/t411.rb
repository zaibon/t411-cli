module API
  module T411

    @@base_url = "https://api.t411.io"
    def auth
      response = HTTParty.post("#{@@base_url}/auth", {body: {username: @config[:t411_user], password: @config[:t411_pass]}})
      response =  JSON.parse(response.body)
      response['token']
    end

    def download_torrents(title, episodes_list)
      torrent_ids = []
      episodes_list.each do |ep|
        torrents = search(title, ep)
        if torrents.count > 0
          torrent_ids << choose_torrent(torrents)
        end
      end
      download(torrent_ids)
    end

    def download(torrent_ids)
      threads = []
      torrent_ids.each do |torrent_id|
        t = Thread.new do
          print"Get #{@@base_url}/torrents/download/#{torrent_id}\n"
          response = HTTParty.get("#{@@base_url}/torrents/download/#{torrent_id}", {headers: {'Authorization' => @config[:t411_token]}})
          path = File.join(File.expand_path('~'), 'Downloads', "#{torrent_id}.torrent")
          file = File.open(path, 'w')
          file.write(response)
          file.close

          if @config[:autodownload_enable] == true
            upload_torrent(path)
          end
        end
        threads << t
      end
      threads.each { |thr| thr.join }
    end

    def search(title, ep)
      uri = URI.encode("#{@@base_url}/torrents/search/#{title} #{ep}")
      response = HTTParty.get(uri, {headers: {'Authorization' => @config[:t411_token]}})
      JSON.parse(response.body)["torrents"]
    end
  end
end
