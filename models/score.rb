module Status
  INACTIVE = 0
  ACTIVE   = 1

  def inactive?
    status == INACTIVE || status == :inactive
  end

  def active?
    status == ACTIVE || status == :active
  end
end

class Score
  include Status

  attr_accessor :time, :home_team, :away_team, :goals, :status, :date,
    :next_game_start_at, :next_game_stadium_at

  def initialize(**attrs)
    attrs.each { |k, v| self.send("#{k}=", v) if self.methods.include?(k) }
    self.goals ||= []
  end

  def to_text
    if inactive?
      return "次節 #{next_game_start_at} #{next_game_stadium_at}\n#{tweet_tags}"
    end

    return '' unless valid_attrs?

    score = "#{time} #{home_team.name}(Home) #{home_team.total_score} vs #{away_team.total_score} #{away_team.name}(Away)"
    goals = self.goals.map do |goal|
      time = goal.first
      getter = goal.second.first

      "#{time} ⚽️ #{getter} \n"
    end.join

    score + "\n" + goals + "\n" + tweet_tags
  end

  private

  def tweet_tags
    '#sanfrecce #jleague #Jリーグ #サンフレッチェ広島 #サンフレッチェ #サンフレ'
  end

  def valid_attrs?
    # NOTE: 試合当日以外に試合スコアが取得できるのはおかしい（スクレイピング先のデータ状態に依存するためここではじく）
    return false unless todays_game?
    return false if home_team.blank? || away_team.blank?
    # NOTE: スコアと得点者をスクレイピングする箇所が異なり、それぞれでデータの更新のタイミングが違うため
    (home_team.total_score + away_team.total_score) == goals.length
  end

  def todays_game?
    date == Date.current
  end
end
