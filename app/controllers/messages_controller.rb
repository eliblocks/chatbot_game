class MessagesController < ApplicationController
  def create
    text = params[:message][:text]
    user = User.find(params[:message][:user_id])
    game = user.active_game
    message = user.messages.new(role: "user", text:, game:)

    message.save

    redirect_to game
  end
end
