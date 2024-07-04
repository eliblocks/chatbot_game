class User < ApplicationRecord
  has_many :messages
  has_and_belongs_to_many :games

  def active_game
    games.active.first
  end
end
