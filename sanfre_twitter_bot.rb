#!/usr/bin/ruby

require './scraper.rb'
require './twitter.rb'
require 'pry-byebug'
require 'dotenv'

module Sanfrecce
  class Bot
    def initialize
      Dotenv.load('.env')
      @scraper = Sanfrecce::Scraper.new
      @twitter = Sanfrecce::Twitter.new
    end

    def tweet
      content = @scraper.result
      return 'There is no content' if @twitter.duplicated_content?(content)
      @twitter.tweet(content)
      content
    end
  end
end

if __FILE__ == $0
  bot = Sanfrecce::Bot.new
  puts bot.tweet
end
