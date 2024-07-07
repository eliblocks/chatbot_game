class MessagesController < ApplicationController
  def create
    text = params[:message][:text]
    user = User.find(params[:message][:user_id])
    message = user.messages.new(role: "user", text:, game: user.game)

    message.save

    redirect_to user.game
  end
end
