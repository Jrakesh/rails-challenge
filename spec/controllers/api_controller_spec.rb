require 'rails_helper'

RSpec.describe ApiController, :type => :controller do

  before(:each) { setup }

  describe "GET leaderboard" do
    it "returns http success" do
      get :leaderboard, level_number: @levels.first.number
      expect(response).to have_http_status(:success)
      expect(JSON.parse response.body).to include({ 'status' => 'success' })
    end

    it "returns a list of top scores per user" do
      opponent = User.create!
      level = @levels.first
      @user.finish_level level, 1000
      @user.finish_level level, 2000
      opponent.finish_level level, 1500
      get :leaderboard, level_number: @levels.first.number
      expect(JSON.parse response.body).to include({
        'leaderboard' => [
          { 'user' => @user.id, 'score' => 2000 },
          { 'user' => opponent.id, 'score' => 1500 },
          #the below hash has been added which was missing. there are two user records/scores and one opponent user record above.
          { 'user' => @user.id, 'score' => 1000 }
        ]
      })

      # Another approach to test.
      expect(JSON.parse(response.body)['leaderboard']).to match_array([
        { 'user' => @user.id, 'score' => 2000 },
        { 'user' => @user.id, 'score' => 1000 },
        { 'user' => opponent.id, 'score' => 1500 },
      ])
    end
  end

  describe "POST finish_level" do
    it "returns http success" do
      post :finish_level, user_id: @user.id, level_number: @levels.first.number
      expect(response).to have_http_status(:success)
      expect(JSON.parse response.body).to include({ 'status' => 'success' })
    end

    it "sets the high score" do
      post :finish_level, user_id: @user.id, level_number: @levels.first.number, score: 2000
      # collect the previous high score.
      older_score = @user.user_levels.find_by!(level: @levels.first).high_score

      post :finish_level, user_id: @user.id, level_number: @levels.first.number, score: 1000

      # test the high scores.
      expect(@user.user_levels.find_by!(level: @levels.first).high_score).not_to eq(older_score)
      expect(@user.user_levels.find_by!(level: @levels.first).high_score).to eq(1000)
    end
  end

end
