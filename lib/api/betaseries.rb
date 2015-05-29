module API
  module Betaseries
    @@base_url = "https://api.betaseries.com"

    def show_id(title)
      uri = URI.encode("#{@@base_url}/shows/search?title=#{title}&summary=true&order=popularity&nbpp=1")
      response = HTTParty.get(uri, {headers: {'X-BetaSeries-Version' => '2.4', 'X-BetaSeries-Key' => @config[:betaserie_key]}})
      response = JSON.parse(response.body)
      response["shows"].first["id"]
    end

    def episodes_list(args)
      title = args[0]
      season = args[1]
      episode = args[2]

      show_id = show_id(title)

      # Then I can call the API to get the episodes list
      uri = "#{@@base_url}/shows/episodes?id=#{show_id}"
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
  end
end