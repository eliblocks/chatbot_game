class User < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :game, optional: true

  def notify_already_playing
    if game
      reply("You are already in game #{game.code}. Message /leave to leave")
    end
  end

  def create_game
    return notify_already_playing if game

    update(game: Game.create(status: "waiting", code: rand(1000..10000)))
    reply("Game created, share the game code #{game.code} to let players join")
  end

  def join_game
    return notify_already_playing if game

    reply("Enter the code for the game you want to join")
  end

  def join_code(code)
    return notify_already_playing if game

    found_game = Game.find_by(code:)

    return reply("Could not find that game") unless found_game
    return reply("This game is not available to join") unless found_game.status == "waiting"

    update(game: found_game)

    reply("Welcome to game #{game.code}. Waiting for players to join (#{game.users.count}/4 players).")

    if game.users.count > 3
      game.update(status: "playing")
      game.initiate
    end
  end

  def leave_game
    return reply("You are not in a game") unless game

    previous_game = game
    update(game: nil)
    previous_game.destroy if previous_game.users.none?

    reply("You have left game #{previous_game.code}")
  end

  def welcome
    reply("Welcome to the chatbot game. type /create to make a new game")
  end

  def reply(text)
    messages.create(role: "assistant", text:, game:).send_to_user
  end
end
