class Api::MessagesController < ActionController::API
  def create
    telegram_id = params["message"]["from"]["id"].to_s
    user = User.find_or_create_by(telegram_id: telegram_id)
    message = user.messages.create(role: "user", text: params["message"]["text"], game: user.game)
    message.handle

    render json: { message: message, messages: Message.includes(:user).as_json(include: :user) }
  end
end
