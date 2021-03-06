# Create custom parser
class TwitterParser < Faraday::Response::Middleware
  METADATA_KEYS = [:completed_in, :max_id, :max_id_str, :next_page, :page, :query, :refresh_url, :results_per_page, :since_id, :since_id_str]

  def on_complete(env)
    json = MultiJson.load(env[:body], :symbolize_keys => true)
    errors = [json.delete(:error)]
    env[:body] = {
      :data => json,
      :errors => errors,
      :metadata => {},
    }
  end
end

TWITTER_CREDENTIALS = {
  :consumer_key => "",
  :consumer_secret => "",
  :token => "",
  :token_secret => ""
}

# Initialize API
Her::API.setup :base_uri => "https://api.twitter.com/1/" do |builder|
  builder.insert 0, FaradayMiddleware::OAuth, TWITTER_CREDENTIALS
  builder.swap Her::Middleware::DefaultParseJSON, TwitterParser
end

# Define classes
class Tweet
  include Her::Model

  def self.timeline
    get "/statuses/home_timeline.json"
  end

  def self.mentions
    get "/statuses/mentions.json"
  end

  def username
    user[:screen_name]
  end
end

get "/" do
  @tweets = Tweet.mentions
  haml :index
end
