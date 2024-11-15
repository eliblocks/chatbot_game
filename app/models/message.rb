class Message < ApplicationRecord
  belongs_to :user
  belongs_to :game, optional: true

  validates :text, presence: true
  validates :role, inclusion: [ "user", "assistant" ]

  def self.formatted
    all.map { |message| { role: message.role, content: message.text } }
  end

  def send_to_user
    return unless user.telegram_id

    token = ENV.fetch("TELEGRAM_TOKEN")

    url = "https://api.telegram.org/bot#{token}/sendMessage"
    json = { text:, chat_id: user.telegram_id }

    HTTP.post(url, json:)
  end

  def handle
    if text.include?("/create")
      user.create_game
    elsif text.include?("/leave")
      user.leave_game
    elsif text.include?("/join")
      user.join_game
    elsif match = text.match(/\A\d{4}\z/)
      user.join_code(match[0])
    elsif !user.game
      user.welcome
    else
      user.game.handle_status(self)
    end
  end
end
