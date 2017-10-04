#!/usr/bin/ruby

require './scraper.rb'
require './twitter.rb'
require 'pry-byebug'
require 'dotenv'
require 'active_support'
require 'active_support/core_ext'

module Sanfrecce
  class Bot
    def initialize
      Dotenv.load('.env')
      @scraper = Sanfrecce::Scraper.new
      @twitter = Sanfrecce::Twitter.new
    end

    def scrape
      @scraper.scrape
    end

    def tweet(content)
      return 'Sanfrecce.tweet There is no content' if content.blank? || @twitter.duplicated_content?(content)
      @twitter.tweet(content)
      content
    end

    def tweet_draft(content)
      return 'Sanfrecce.tweet_draft There is no content' if content.blank? || @twitter.duplicated_content?(content)
      content
    end
  end
end

if __FILE__ == $0
  bot        = Sanfrecce::Bot.new
  score_json = bot.scrape

  score           = Score.new(score_json[:score])
  score.home_team = Team.new(score_json[:home])
  score.away_team = Team.new(score_json[:away])

  # puts bot.tweet(score.to_text)
  puts bot.tweet_draft(score.to_text)
end
