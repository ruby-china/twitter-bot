require 'faraday'
require 'twitter'
require 'json'
require 'date'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.bearer_token        = ENV['BEARER_TOKEN']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

INTERVAL = 24 * 60 * 60 # 1 day

resp = Faraday.get(
  'https://ruby-china.org/api/v3/topics',
  { type: 'excellent' },
  { 'Accept': 'application/json' }
)

topics = JSON.parse(resp.body)['topics']

filtered = topics.reject do |topic|
  Time.now - DateTime.parse(topic['created_at']).to_time > INTERVAL
end

formatted = filtered.map do |topic|
  "《#{topic['title']}》作者：#{topic['user']['name']}\n\nhttps://ruby-china.org/topics/#{topic['id']}"
end

formatted.each do |tweet|
  client.update(tweet)
end

puts 'OK!'
