require 'rails_helper'

RSpec.describe User do

  before(:each) { setup }

  describe "#level_attempts" do
    it "returns all level attempts for this user" do
      user_levels = @levels[0..3].map do |level|
        @user.user_levels.create! level: level
      end
      3.times { user_levels[0].attempts.create! score: random_score }
      2.times { user_levels[1].attempts.create! score: random_score }
      4.times { user_levels[2].attempts.create! score: random_score }
      expect(@user.level_attempts.length).to eq(9)
    end
  end

  describe "#finish_level" do
    it "should create a user_level the first time the user completes the level" do
      @user.finish_level(@levels[0], random_score)
      expect(@user.user_levels.length).to eq(1)
    end

    it "should set the high score" do
      @user.finish_level(@levels[0], 10000)
      @user.finish_level(@levels[0], 20000)
      user_level = @user.user_levels.find_by! level: @levels[0]
      expect(user_level.attempts.length).to eq(2)
      expect(user_level.high_score).to eq(20000)
    end
  end

  def random_score
    rand(1..100) * 1000
  end

end
