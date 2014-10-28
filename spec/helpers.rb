module Helpers
  def setup
    @user = User.create!
    @levels = (1..10).map { |n| Level.create! number: n }
    @levels.each_cons(2) do |level, next_level|
      level.update! next_level: next_level
    end
  end
end
