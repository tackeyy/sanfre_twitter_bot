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

  attr_accessor :time, :home_team, :away_team, :goals, :status,
    :next_game_start_at, :next_game_stadium_at

  def initialize(**attrs)
    attrs.each { |k, v| self.send("#{k}=", v) if self.methods.include?(k) }
    self.goals ||= []
  end

  def to_text
    if inactive?
      return "次節 #{result[:next_geme_start_at]} #{result[:next_game_stadium_at]}\n#{tweet_tags}"
    end

    return '' if home_team.blank? || away_team.blank?

    score = "#{time} #{home_team.name}(Home) #{home_team.total_score} vs #{away_team.name}(Away) #{away_team.total_score}\n"
    # TODO: なぜかselfをつけないと値が取れない
    goals = "#{self.goals.join("\n")}\n"

    score + goals + tweet_tags
  end

  private

  def tweet_tags
    '#sanfrecce #jleague #サンフレッチェ広島 #サンフレッチェ #サンフレ'
  end
end
