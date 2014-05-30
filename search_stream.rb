require 'tweetstream'
require "rubygems"
require 'sequel'
require 'logger'


# DB = Sequel.sqlite("tweets.db")
# tweets = DB[:tweets]

path = File.dirname(File.expand_path(__FILE__))
#log = Logger.new('collect_tweets.log')
log = Logger.new(path + "/" + 'collect_tweets.log')

#connect to db
tweets = Sequel.sqlite(path + "/" + "tweets.db")[:tweets]

#create logfile
# log = Logger.new("collect_tweets.log")
log.info "Started"

#authenticate with twitter
TweetStream.configure do |config|
  config.consumer_key       = 'ol7vjVmcHnVL6QrOAXepCUsOL'
  config.consumer_secret    = 'oKkuicfLgk9Ejr4Uqg74QxG2jKPxaHXtIZrhYjuZKTH1mRbkQr'
  config.oauth_token        = '26695303-wbAAKYS5B85jhRLbv9Ltf0iq5vhTfTMZ8QC15Q43T'
  config.oauth_token_secret = 'AASZiWJk5y2WYyTaDCH5dU4oPS58bYbg9pdHvVTwcLFfR'
  config.auth_method        = :oauth
end

@client = TweetStream::Client.new
do_once = true
first_tweet = true

@client.on_delete do |status_id, user_id|
 log.error "Tweet deleted"
end

@client.on_limit do |skip_count|
 log.error "Limit exceeded"
end

#start stream
# #if search
@client.track('*') do |status|

  # if user
  #@client.userstream do |status|
    
  begin
   tweets.insert(
    :text => status.text,
    :username => status.user.screen_name,
    :created_at => status.created_at,
    :lang => status.user.lang,
    :time_zone => status.user.time_zone,
    :guid => status.user.id,
    )
    puts "---------------------------------"
    puts "User:#{status.user.screen_name}"
    puts "Tweet:#{status.text}"
    puts "Time:#{status.created_at}"
    puts "---------------------------------"
    
    rescue
      log.fatal "Could not insert tweet. Possibly db lock error"
      #puts "Couldnt insert tweet. Possibly db lock error"
    end

    if first_tweet == true
      log.info "First tweet"
      first_tweet = false
    end

    #confirm running every 10 minutes
    time = Time.now.min
    if time % 10  == 0 && do_once == true
     log.info "Collection up and running"
     do_once = false
    elsif time  % 10 != 0
      do_once = true
    end
end

    
