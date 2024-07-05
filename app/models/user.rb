class User < ApplicationRecord
  has_many :messages
  has_and_belongs_to_many :games

  def active_game
    games.active.first
  end

  def respond
    last_message = messages.last
    if last_message.text.include?("/create")
      game = Game.create(status: "waiting", code: rand(1000..10000))
      text = "Game created, share the game code #{game.code} to let players join"
    elsif last_message.text.include?("/leave")
      game = active_game
      if game
        GamesUsers.find_by(user_id: id, game_id: active_game.id).destroy
        if game.users.none?
          game.destroy
        end
        text = "You have left game #{game.code}"
      else
        text = "You are not in a game"
      end
    elsif last_message.text.include?("/join")
      text = "Enter the code for the game you want to join"
    elsif match = last_message.text.match(/\A\d{4}\z/)
      game = Game.find_by(code: match[0])
      if active_game && active_game != game
        text = "You are already in game #{active_game.code}. Message /leave to leave"
      elsif !game
        text = "Could not find that game"
      elsif game.status != "waiting"
        text = "This game is not available to join"
      elsif game.status == "waiting"
        game.users << self
        text = "Welcome to game #{game.code}. Waiting for players to join. #{game.users.count}/4 players waiting"
        if game.users.count > 3
          game.update(status: "playing")
          game.initiate
        end
      end
    else
      text = "Thank you for playing"
    end

    messages.create(role: "assistant", text:).send_to_user
  end
end
