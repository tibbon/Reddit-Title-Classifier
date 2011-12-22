require 'httparty'
require 'json'
require 'sequel'
require 'logger'
require 'mysql'

config = begin
  YAML.load(File.open("config.yaml"))
rescue ArgumentError => e
  puts "Could not parse YAML: #{e.message}"
end

username = config["mysql_settings"]["username"]
password = config["mysql_settings"]["password"]
ip = config["mysql_settings"]["ip"]
port = config["mysql_settings"]["port"]
database = config["mysql_settings"]["database"]
log_location = config["mysql_settings"]["log_location"]

DB = Sequel.connect("mysql://#{username}:#{password}@#{ip}:#{port}/#{database}", :logger => Logger.new("#{log_location}"))

unless DB.table_exists?(:submissions) 
  DB.create_table :submissions do
    primary_key :id
    varchar     :title
    varchar     :subreddit
    varchar     :name, :unique => true
    integer     :ups
    integer     :downs
    integer     :score
    varchar     :author
    varchar     :domain
    text        :selftext
    varchar     :media
    varchar     :url
    varchar     :thumbnail
    integer     :num_comments
    varchar     :created_utc     
  end
end

class Submission < Sequel::Model
end

#@seed = DB["select name from submissions ORDER BY FROM_UNIXTIME(created_utc) DESC LIMIT 1;"]
@seed = "3_nlyxy"
