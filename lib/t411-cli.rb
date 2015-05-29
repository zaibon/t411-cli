require 'commander/import'
require 'rainbow'
require 'httparty'
require 'uri'
require 'json'
require 'yaml'
require 'net/scp'

require File.join(File.dirname(__FILE__), "/api/betaseries.rb")
require File.join(File.dirname(__FILE__), "/api/t411.rb")

module T411Cli
  include API::Betaseries
  include API::T411

  def init_cli
    begin
      @config = read_config()
    rescue
      puts Rainbow('No configuration file found. Please run "t411 configure" first.').red
      exit!
    end

    program :version, '0.0.1'
    program :description, 'cli T411 that allows to download torrent files from the terminal through T411\'s API'
  end

  def read_config
    YAML.load_file(File.join(File.expand_path('~'), '.t4111'))
  end

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

require File.join(File.dirname(__FILE__), "../lib/commands/config.rb")
require File.join(File.dirname(__FILE__), "../lib/commands/download.rb")