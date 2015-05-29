command "download-serie".to_sym do |c|
  c.syntax = 't411 download title [season] [episode]'
  c.summary = 'Download torrents that matches the arguments'

  c.description = "Download torrents that matches the arguments\n"
  c.description+= "It is important to wrap the title between double quotes to avoid the app to misinterpret it.\n"
  c.description+= "If a season is passed in arguments only episodes corresponding to this season will be downloaded.\n"
  c.description+= "If an episode is passed in arguments only the episode from the season will be downloaded"

  c.example 'Download all the episodes of the show Breaking Bad', 't411 download "breaking bad"'
  c.example 'Download all the episodes of the show The Walking Dead of season 3', 't411 download "the walking dead" 3'
  c.example 'Download the episode 2 of the season 1 of the show Better Call Saul', 't411 download "better call saul" 1 2'

  c.action do |args, options|
    if args.count < 1
      puts Rainbow("You have to pass at least a title. Please try again and run t411 help download if you need help.").red
      exit(0)
    end

    episodes_list = episodes_list(args)
    @config[:t411_token] = auth
    torrents_path = download([args.first, episodes_list])
    if @config[:autodownload_enable] == true
      upload_torrent(torrents_path)
    end
  end
end