require "ruby_reddit_api"
require "pp"
require_relative 'model'


def query_reddit(subreddit,start_point)  
  #if count.nil?
  #  url = "http://www.reddit.com/r/guitar/new/.json?limit=100"
  #else
  #  url = "http://www.reddit.com/r/guitar/new/.json?limit=100&count=#{count}&after=#{start_point}" #t3_nlz9o
  #end
  #response = JSON.parse HTTParty.get(url).response.body
  #pp response
  #end_point = response["data"]["after"]
  #response = response["data"]["children"]
  #response.sort! { |a,b| b["data"]["created_utc"].to_i <=> a["data"]["created_utc"].to_i}
  end_point = nil
  r = Reddit::Api.new @reddit_username, @reddit_password
  r.login
  if start_point.empty?
    response = r.browse "#{subreddit}/new", {:limit => 100, :sort => "new"}
  else
    response = r.browse "#{subreddit}/new", {:limit => 100, :sort => "new", :after => start_point}
  end
  
  end_point = response.first[:after]
  p "Query: " + start_point
  p "Next page: " + end_point
  response.each do |submission|
    begin
      p submission.title
      Submission.create(
      :title => submission.title,
      :subreddit => submission.subreddit,
      :name => submission.name,
      :ups => submission.ups,
      :downs => submission.downs,
      :score => submission.score,
      :author => submission.author,
      :domain => submission.domain,
      :selftext => submission.selftext,
      :media => submission.media,
      :url => submission.url,
      :thumbnail => submission.thumbnail,
      :num_comments => submission.num_comments,
      :created_utc => submission.created_utc)
    rescue
    end
  end
  return end_point
end

next_seed = "t3_nlmry"
subreddit = "all"
100.times do 
  next_seed = query_reddit(subreddit,next_seed)
end
