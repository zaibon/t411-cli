module API
  module Betaseries
    @@base_url = "https://api.betaseries.com"

    def show_id(title)
      uri = URI.encode("#{@@base_url}/shows/search?title=#{title}&summary=true&order=popularity&nbpp=1")
      response = HTTParty.get(uri, {headers: {'X-BetaSeries-Version' => '2.4', 'X-BetaSeries-Key' => @config[:betaserie_key]}})
      id = parse_show_id_response(response)
      id
    end

    def parse_show_id_response(response)
      response = JSON.parse(response.body)
      return response["shows"].first["id"] unless response['shows'].empty?
      nil
    end

    def episodes_list(args)
      title = args[0]
      season = args[1]
      episode = args[2]

      show_id = show_id(title)
      if show_id.nil?
        puts Rainbow("The series \"#{title}\" doens't exist.").red
        exit(0)
      end

      # Then I can call the API to get the episodes list
      uri = "#{@@base_url}/shows/episodes?id=#{show_id}"
      uri += "&season=#{season}" unless season.nil?
      uri += "&episode=#{episode}" unless episode.nil?
      uri = URI.encode(uri)
      response = HTTParty.get(uri, {headers: {'X-BetaSeries-Version' => '2.4', 'X-BetaSeries-Key' => @config[:betaserie_key]}})
      episodes = parse_episodes_list_response(response)
      episodes
    end

    def parse_episodes_list_response(response)
      response = JSON.parse(response.body)
      episodes = []
      response["episodes"].each do |ep|
        episodes << ep['code']
      end
      episodes
    end
  end
end
