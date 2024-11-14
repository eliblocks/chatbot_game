class MessagesController < ApplicationController
  def create
    user = User.find_or_create_by(id: params[:message][:user_id])
    text = params[:message][:text]

    message = user.messages.create(role: "user", text:, game: user.game)
    message.handle

    redirect_to user.game
  end
end
