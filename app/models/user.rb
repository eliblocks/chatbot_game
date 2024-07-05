class User < ApplicationRecord
  has_many :messages
  has_and_belongs_to_many :games

  def active_game
    games.active.first
  end

  def notify_already_playing
    if active_game
      reply("You are already in game #{active_game.code}. Message /leave to leave")
    end
  end

  def create_game
    return notify_already_playing if active_game

    game = Game.create(status: "waiting", code: rand(1000..10000))
    game.users << self
    reply("Game created, share the game code #{game.code} to let players join")
  end

  def join_game
    return notify_already_playing if active_game

    reply("Enter the code for the game you want to join")
  end

  def join_code(code)
    return notify_already_playing if active_game

    game = Game.find_by(code:)

    return reply("Could not find that game") unless game
    return reply("This game is not available to join") unless game.status == "waiting"

    game.users << self

    reply("Welcome to game #{game.code}. Waiting for players to join. #{game.users.count}/4 players waiting")

    if game.users.count > 3
      game.update(status: "playing")
      game.initiate
    end
  end

  def leave_game
    game = active_game
    return reply("You are not in a game") unless game

    GamesUsers.find_by(user: self, game:).destroy
    game.destroy if game.users.none?

    reply("You have left game #{game.code}")
  end

  def welcome
    reply("Welcome to the chatbot game. type /create to make a new game")
  end

  def reply(text)
    messages.create(role: "assisstant", text:).send_to_user
  end
end
