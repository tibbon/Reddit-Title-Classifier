require_relative 'model'


def query_reddit(start_point, count)  
  if count.nil?
    url = "http://www.reddit.com/r/all/new/.json?limit=100"
  else
    url = "http://www.reddit.com/r/all/new/.json?limit=100&count=#{count}&after=#{start_point}"
  end
  response = JSON.parse HTTParty.get(url).response.body
  
  end_point = response["data"]["after"]
  response = response["data"]["children"]
  response.sort! { |a,b| b["data"]["created_utc"].to_i <=> a["data"]["created_utc"].to_i}
  response.each do |submission|
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
    rescue
    end
    p submission["data"]["name"] + " " + Time.at(submission["data"]["created_utc"]).to_s
  end
  return end_point
end

@count = nil
next_seed = query_reddit(@seed, @count)
@count = 0
100000.times do 
  p @count += 100
  p ""
  #p next_seed
  next_seed = query_reddit(next_seed, @count)
end
