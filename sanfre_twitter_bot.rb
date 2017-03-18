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

    def game_result
      @scraper.result
    end

    def tweet(content)
      @twitter.tweet(content)
    end
  end
end

if __FILE__ == $0
  bot = Sanfrecce::Bot.new
  game_result = bot.game_result
  puts game_result
  #puts bot.tweet(game_result)
end
