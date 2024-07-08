require "rails_helper"

RSpec.describe Message do
  let(:user) { User.create }

  describe '#handle' do
    context 'a new user is creating a game' do
      it 'creates a game' do
        message = user.messages.create(role: "user", text: "/create")

        message.handle

        game = Game.last
        new_message = Message.last

        expect(game).not_to be_nil
        expect(game.users).to include(user)
        expect(new_message.text).to include("Game created")
      end
    end

    context 'a user tries to create a game while already playing' do
      it 'informs the user' do
        game = Game.create(status: "waiting", code: "4444")
        game.users << user
        message = user.messages.create(role: "user", text: "/create")

        message.handle
        new_message = Message.last

        expect(user.game).to eq(game)
        expect(Game.count).to eq(1)
        expect(new_message.text).to include("already")
      end
    end

    context 'a user tries to join a game while already in a game' do
      it 'informs the user' do
        game = Game.create(status: "waiting", code: "4444")
        game.users << user
        message = user.messages.create(role: "user", text: "/join")

        message.handle
        new_message = Message.last

        expect(user.game).to eq(game)
        expect(Game.count).to eq(1)
        expect(new_message.text).to include("already")
      end
    end

    context 'a user tries to leave a game without being in a game' do
      it 'informs the user' do
        message = user.messages.create(role: "user", text: "/leave")

        message.handle
        new_message = Message.last

        expect(new_message.text).to include("You are not in a game")
      end
    end

    context 'a user types the join command' do
      it 'informs the user to enter a code' do
        message = user.messages.create(role: "user", text: "/join")

        message.handle
        new_message = Message.last

        expect(new_message.text).to include("code")
      end
    end

    context 'a user types in an invalid game code' do
      it 'informs the user' do
        message = user.messages.create(role: "user", text: "1234")

        message.handle
        new_message = Message.last

        expect(new_message.text).to include("not find")
      end
    end

    context 'a user types in a game code that is already playing' do
      it 'informs the user' do
        Game.create(status: "finished", code: "1234")
        message = user.messages.create(role: "user", text: "1234")

        message.handle
        new_message = Message.last

        expect(new_message.text).to include("not available")
      end
    end

    context 'a user enters a valid game code' do
      it 'adds the user to the game' do
        game = Game.create(status: "waiting", code: "1234")
        game.users << User.create
        message = user.messages.create(role: "user", text: "1234")

        message.handle
        new_message = Message.last

        expect(game.users).to include(user)
        expect(new_message.text).to include("Waiting for players")
      end
    end

    context 'a user leaves a game' do
      it 'removes the user' do
        game = Game.create(status: "waiting", code: "1234")
        game.users << User.create
        game.users << user
        message = user.messages.create(role: "user", text: "/leave")

        message.handle
        new_message = Message.last

        expect(game.users).not_to include(user)
        expect(new_message.text).to include("You have left")
      end
    end

    context 'when a user not in a game sends a message' do
      it 'welcomes the user with instructions' do
        message = user.messages.create(role: "user", text: "Hello")

        message.handle
        new_message = Message.last

        expect(new_message.text).to include("Welcome")
      end
    end

    context 'when a user waiting to play sends a message' do
      it 'responds with a count of players' do
        game = Game.create(status: "waiting", code: "1234")
        game.users << user
        message = user.messages.create(role: "user", text: "Hello")

        message.handle
        new_message = Message.last

        expect(new_message.text).to include("Waiting")
      end
    end

    context 'when a user in middle of a game sends a message' do
      it 'replies with a message' do
        game = Game.create(status: "playing", code: "1234")
        game.users << user
        message = user.messages.create(role: "user", text: "Hello")

        message.handle
        new_message = Message.last

        expect(new_message.text).to be_a String
      end
    end
  end
end
