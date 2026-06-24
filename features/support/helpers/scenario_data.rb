# frozen_string_literal: true

class ScenarioData
  attr_accessor :users_full_info, :users_id, :last_generated

  def initialize
    @users_id = {}
    @last_generated = {}
  end
end
