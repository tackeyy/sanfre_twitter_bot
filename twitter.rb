require 'twitter'
require 'pry-byebug'

module Sanfrecce
  class Twitter
    ACCOUNT_NAME = 'sanfre_bot'.freeze

    def initialize
      @client = ::Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['CONSUMER_KEY']
        config.consumer_secret     = ENV['CONSUMER_SECRET']
        config.access_token        = ENV['ACCESS_TOKEN']
        config.access_token_secret = ENV['ACCESS_SECRET']
      end
    end

    def tweet(content)
      @client.update(content)
    end

    def duplicated_content?(tweet_content)
      @client.user_timeline("#{ACCOUNT_NAME}", { count: 1 }).any? do |timeline|
        @client.status(timeline.id).text == tweet_content
      end
    end
  end
end
