class GamesController < ApplicationController
  def index
    @game = Game.all
  end

  def show
    @game = Game.find(params[:id])
  end

  def create
    @game = Game.create(status: "playing", code: rand(1000..10000))
    @game.users << [ User.create, User.create, User.create, User.create ]
    @game.initiate

    redirect_to game_path(@game)
  end
end
