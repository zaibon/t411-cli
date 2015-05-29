command :configure do |c|
  c.syntax = 't411 configure'
  c.summary = 'Configure the app before the first use'

  c.description = "Configure the app before the first use. It creates a .t411 file in the user home directory"

  c.example 'Launch the configuration', 't411 configuration'

  c.action do |args, options|
    config = {}
    print Rainbow('T411 login : ').blue
    config[:t411_user] = STDIN.gets.chomp
    print Rainbow('T411 password : ').blue
    config[:t411_pass] = STDIN.gets.chomp
    print Rainbow('Betaserie API key : ').blue
    config[:betaserie_key] = STDIN.gets.chomp
    loop do
      print Rainbow('enable auto upload torrent to a remote server ? (y/n) : ').blue
      res = STDIN.gets.chomp
      if res.downcase == "y"
        print Rainbow('server host : ').blue
        config[:autodownload_host] = STDIN.gets.chomp
        print Rainbow('server username : ').blue
        config[:autodownload_username] = STDIN.gets.chomp
        print Rainbow('server folder : ').blue
        config[:autodownload_path] = STDIN.gets.chomp
        config[:autodownload_enable] = true
        break
      elsif res.downcase == 'n'
        break
      end
    end
    print "Writing config file... "
    config = config.to_yaml
    file = File.open(File.join(File.expand_path('~'), '.t411'), 'w')
    file.write(config)
    file.close
    puts Rainbow("[OK]").green
  end
end