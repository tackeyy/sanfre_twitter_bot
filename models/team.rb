class Team
  attr_accessor :name, :first_score, :second_score

  def initialize(**attrs)
    attrs.each { |k, v| self.send("#{k}=", v) if self.methods.include?(k) }
  end

  def total_score
    first_score.to_i + second_score.to_i
  end
end
