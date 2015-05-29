module API
  module T411

    @@base_url = "https://api.t411.io"
    def auth
      response = HTTParty.post("#{@@base_url}/auth", {body: {username: @config[:t411_user], password: @config[:t411_pass]}})
      response =  JSON.parse(response.body)
      response['token']
    end

    def download(args)
      title = args[0]
      episodes_list = args[1]
      torrents_file = []
      episodes_list.each do |ep|
        torrents = search(title, ep)
        torrent_id = choose_torrent(torrents)
        response = HTTParty.get("#{@@base_url}/torrents/download/#{torrent_id}", {headers: {'Authorization' => @config[:t411_token]}})
        path = File.join(File.expand_path('~'), 'Downloads', "#{title}-#{ep}.torrent")
        file = File.open(path, 'w')
        file.write(response)
        file.close
        torrents_file << path
      end
      torrents_file
    end

    def search(title, ep)
      uri = URI.encode("#{@@base_url}/torrents/search/#{title} #{ep}")
      response = HTTParty.get(uri, {headers: {'Authorization' => @config[:t411_token]}})
      JSON.parse(response.body)["torrents"]
    end
  end
end