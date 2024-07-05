class Api::MessagesController < ActionController::API
  def create
    role = "user"
    telegram_id = params["message"]["from"]["id"].to_s
    user = User.find_or_create_by(telegram_id: telegram_id)
    text = params["message"]["text"]
    user.messages.create(role:, text:)
    user.respond
  end
end
