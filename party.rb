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

seed = DB["SELECT name FROM submissions ORDER BY id DESC LIMIT 1"].first[:name]

if seed == nil 
  seed = "t3_nhypy"
end

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
  plugin :validation_helpers
  
  def validate
    validates_unique :name
  end
end

def query_reddit(start_point)
  end_point = String.new
  response = JSON.parse HTTParty.get("http://www.reddit.com/r/all/new/.json?sort=new&count=1&limit=100&after=#{end_point}").response.body
  response["data"]["children"].each do |submission|
    begin
      Submission.create(
      :title => submission["data"]["title"],
      :subreddit => submission["data"]["subreddit"],
      :name => submission["data"]["name"],
      :ups => submission["data"]["ups"],
      :downs => submission["data"]["downs"],
      :score => submission["data"]["score"],
      :author => submission["data"]["author"],
      :domain => submission["data"]["domain"],
      :selftext => submission["data"]["selftext"],
      :media => submission["data"]["media"],
      :url => submission["data"]["url"],
      :thumbnail => submission["data"]["thumbnail"],
      :num_comments => submission["data"]["num_comments"],
      :created_utc => submission["data"]["created_utc"])
    rescue Sequel::ValidationFailed
    end
    end_point = submission["data"]["name"]
  end
  return end_point
end

next_seed = query_reddit(seed)
x = 1
100000.times do 
  p x += 1
  next_seed = query_reddit(next_seed)
end
