class Message < ApplicationRecord
  belongs_to :user
  belongs_to :game, optional: true

  validates :text, presence: true

  def send_to_user
    return unless user.telegram_id

    token = ENV.fetch("TELEGRAM_TOKEN")

    url = "https://api.telegram.org/bot#{token}/sendMessage"
    json = { text:, chat_id: user.telegram_id }

    HTTP.post(url, json:)
  end
end
