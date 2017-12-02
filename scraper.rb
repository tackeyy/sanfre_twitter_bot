require 'mechanize'
require 'nokogiri'
require './models/score.rb'
require './models/team.rb'

module Sanfrecce
  URL = 'http://soccer.yahoo.co.jp/jleague/league/j1'.freeze

  class Scraper
    def initialize
      @agent = Mechanize.new
    end

    def scrape
      page = @agent.get(URL)
      elements = page.search('div[@class="modBody"]//tbody//tr')

      tr_element = get_sanfre_tr(elements)
      score_href = get_score_href(tr_element)

      score_page = page.link_with(href: score_href.text).click
      get_game_detail_json(score_page)
    end

    private

    def get_sanfre_tr(elements)
      elements.each do |element|
        return element if exists_sanfre?(element)
      end
    end

    def exists_sanfre?(tr_element)
      tr_element.xpath('td').each do |td|
        return true if td.text.strip == '広島'
      end
      false
    end

    def get_score_href(tr_element)
      tr_element.xpath('td[@class="score"]/a/@href')
    end

    def get_game_detail_json(score_page)
      time = ''
      home_team_name = ''
      away_team_name = ''
      home_first_score = ''
      home_second_score = ''
      away_first_score = ''
      away_second_score = ''

      score_page.search('div[@class="scoreBoard"]').each do |div|
        first_half_score_html = div.search('table[@class="score"] tr')
        second_half_score_html = div.search('table[@class="score"] tr[@class="last"]')

        home_first_score = first_half_score_html.search('td[@class="home first"]').text()
        home_second_score = second_half_score_html.search('td[@class="home second"]').text()
        away_first_score = first_half_score_html.search('td[@class="away first"]').text()
        away_second_score = second_half_score_html.search('td[@class="away second"]').text()

        home_team_html = div.search('div[@class="homeTeam team"]')
        home_team_name = home_team_html.search('div[@class="name"]').text()

        away_team_html = div.search('div[@class="awayTeam team"]')
        away_team_name = away_team_html.search('div[@class="name"]').text()

        time_html = div.search('div[@class="main"]')
        time = time_html.search('div[@class="status"]').text()
      end

      if time == '試合前'
        score_page.search('div[@class="note"]').each do |div|
          return {
            score: {
              status:               :inactive,
              date:                 url_to_date(url: score_page.uri.to_s),
              next_game_start_at:   div.search('dl[@class="time"]').text(),
              next_game_stadium_at: div.search('dl[@class="stadium"]').text()
            }
          }
        end
      end

      goals = []
      score_page.search('div[@class="gameSummaryBody partsTable"]//tbody//tr').each do |tr|
        next if tr.search('td//em[@class="goal"]').blank?
        goal_time    = tr.search('th[@class="time"]').children.first.text.strip
        goal_getters = tr.search('td').text().split("\n")
        goals.push([goal_time, goal_getters])
      end

      {
        score: {
          date:   url_to_date(url: score_page.uri.to_s),
          time:   time,
          goals:  goals,
          status: :active
        },
        home: {
          name:         home_team_name,
          first_score: home_first_score,
          second_score: home_second_score
        },
        away: {
          name:         away_team_name,
          first_score: away_first_score,
          second_score: away_second_score
        }
      }
    end

    def url_to_date(url: nil)
      Date.parse(url.split('/').last)
    end
  end
end
