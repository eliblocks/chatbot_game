class Game < ApplicationRecord
  has_many :users
  has_many :messages, dependent: :destroy

  validates :status, inclusion: [ "waiting", "playing", "finished" ]

  scope :active, -> { where(status: [ "waiting", "playing" ]) }

  def system_prompt
    "The user is guessing a number (1-100). The number is #{secret_number}. Without telling the user the secret number, give them a hint from popular culture if they guess incorrectly"
  end

  def formatted_messages(user)
    [ { role: "system", content: system_prompt } ] + user_messages(user).formatted
  end

  def initiate
    users.each do |user|
      text = "Lets Play! You are Player #{player_number(user)}"
      Message.create(role: "assistant", text:, user:).send_to_user

      text = "Guess the secret number (1-100)"
      Message.create(role: "assistant", text:, user:).send_to_user
    end
  end

  def secret_number
    ((created_at.to_i % 100) + 1).to_s
  end

  def handle_status(message)
    if status == "waiting"
      message.user.reply("Waiting for more players (#{users.count}/4)")
    elsif status == "finished"
      message.user.reply("This game is already over")
    elsif status == "playing"
      play(message)
    end
  end

  def play(message)
    if message.text == secret_number
      declare_winner(message.user)
    else
      hint(message.user)
    end
  end

  def declare_winner(winner)
    update(status: "finished")

    users.each do |user|
      if user == winner
        user.reply("Congratulations Player #{player_number(user)}, you win!!")
      else
        user.reply("Better luck next time, Player #{player_number(winner)} got the answer (#{secret_number}) first.")
      end
    end

    users.update_all(game_id: nil)
  end

  def player_number(user)
    users.ids.index(user.id)
  end

  def user_messages(user)
    messages.where(user:)
  end

  def hint(user)
    user.reply(response(user))
  end

  def chat(user)
    OpenAI::Client.new.chat(
      parameters: {
        model: "gpt-4o",
        messages: formatted_messages(user),
        temperature: 0.5
      }
    )
  end

  def response(user)
    chat(user).dig("choices", 0, "message", "content")
  end
end
