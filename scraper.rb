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
          return Score.new(
            status:               :inactive,
            next_geme_start_at:   div.search('dl[@class="time"]').text(),
            next_geme_stadium_at: div.search('dl[@class="stadium"]').text()
          )
        end
      end

      goals = []
      score_page.search('div[@class="gameSummaryBody partsTable"]//tbody//tr').each do |tr|
        next if tr.search('td//em[@class="goal"]').blank?
        goal_time   = tr.search('th[@class="time"]').children.first.text.strip
        goal_getter = tr.search('td').text.gsub('得点：', '')
        goals.push("#{goal_time}#{goal_getter}")
      end

      {
        score: {
          time:   time,
          goals:  goals,
          status: :active
        },
        home: {
          name:         home_team_name,
          second_first: home_first_score,
          second_score: home_second_score
        },
        away: {
          name:         away_team_name,
          second_first: away_first_score,
          second_score: away_second_score
        }
      }
    end

    def to_result_txt(result)
      if result[:next_geme_starts_at].present?
        return "次節 #{result[:next_geme_starts_at]} #{result[:next_geme_at]}\n#sanfrecce #jleague"
      end

      return '' if result[:home_team].blank? || result[:away_team].blank?

      score = "#{result[:time]} #{result[:home_team]}(Home) #{result[:score][:home][:total]} vs #{result[:score][:away][:total]} #{result[:away_team]}(Away)\n"
      goals = "#{result[:goals].join("\n")}\n"
      tags  = "#sanfrecce #jleague"
      score + goals + tags
    end
  end
end
