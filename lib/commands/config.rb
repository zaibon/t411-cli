command :configure do |c|
  c.syntax = 't411 configure'
  c.summary = 'Configure the app before the first use'

  c.description = "Configure the app before the first use. It creates a .t411 file in the user home directory"

  c.example 'Launch the configuration', 't411 configuration'

  c.action do |args, options|
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
end
