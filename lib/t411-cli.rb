require 'commander/import'
require 'rainbow'
require 'httparty'
require 'uri'
require 'json'
require 'yaml'
require 'net/scp'

require File.join(File.dirname(__FILE__), "/api/betaseries.rb")
require File.join(File.dirname(__FILE__), "/api/t411.rb")
require File.join(File.dirname(__FILE__), "utils.rb")
require File.join(File.dirname(__FILE__), "t411-cli/version.rb")

module T411Cli
  include API::Betaseries
  include API::T411
  include Utils

  def start
    begin
      @config = read_config()
    rescue
      puts Rainbow('No configuration file found. Please run "t411 configure" first.').red
      exit!
    end

    program :version, T411Cli::VERSION 
    program :description, 'cli T411 that allows to download torrent files from the terminal through T411\'s API'
  end

  def read_config
    YAML.load_file(File.join(File.expand_path('~'), '.t411'))
  end

end

require File.join(File.dirname(__FILE__), "../lib/commands/config.rb")
require File.join(File.dirname(__FILE__), "../lib/commands/download.rb")
