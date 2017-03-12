require 'mechanize'
require 'nokogiri'

module Sanfrecce
  URL = 'http://soccer.yahoo.co.jp/jleague/league/j1'

  class Scraper
    def initialize
      @agent = Mechanize.new
    end

    def result
      page = @agent.get(URL)
      elements = page.search('div[@class="modBody"]//tbody//tr')

      tr_element = get_sanfre_tr(elements)
      score_href = get_score_href(tr_element)

      score_page = page.link_with(href: score_href.text).click
      result = get_hoge_href(score_page)
      to_result_txt(result)
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

    def get_hoge_href(score_page)
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
      end

      {
        home_team: home_team_name,
        away_team: away_team_name,
        score: {
          home: {
            first: home_first_score,
            second: home_second_score,
            total: home_first_score.to_i + home_second_score.to_i
          },
          away: {
            first: away_first_score,
            second: away_second_score,
            total: away_first_score.to_i + away_second_score.to_i
          }
        }
      }
    end

    def to_result_txt(result)
      "#{result[:home_team]}(Home) #{result[:score][:home][:total]} vs  #{result[:score][:away][:total]} #{result[:away_team]}(Away)"
    end
  end
end
