require "rails_helper"

RSpec.describe Game do
  describe "#play" do
    let(:game) { Game.create(status: "playing", code: "1234") }
    let(:users) do
      collect = []
      4.times { collect << User.create(game:) }
      collect
    end

    context "when a player wins" do
      it "declares them the winner" do
        winner = users.sample

        message = winner.messages.create(role: "user", text: game.secret_number.to_s)

        game.play(message)

        expect(game.reload.status).to eq("finished")
        expect(winner.messages.last.text).to include("Congratulations")

        loser = (users - [ winner ]).first

        expect(loser.messages.last.text).to include("Better luck")
        expect(loser.messages.last.text).to include("Player #{game.player_number(winner)}")

        expect(winner.reload.game).to eq(nil)
        expect(loser.reload.game).to eq(nil)
      end
    end
  end

  describe "#formatted_messages" do
    let(:game) { Game.create(status: "playing", code: "1234") }
    let(:users) do
      collect = []
      4.times { collect << User.create(game:) }
      collect
    end

    before do
      users.first.messages.create(role: "user", text: "5", game: game)
      users.first.messages.create(role: "assistant", text: "Try again", game: game)
    end

    it "returns a list of messages formatted for chatgpt" do
      messages = game.formatted_messages(users.first)

      expect(messages).to eq([
        { role: "system", content: game.system_prompt },
        { role: "user", content: "5" },
        { role: "assistant", content: "Try again" }
      ])
    end
  end

  describe "#handle_status" do
    let(:game) { Game.create(status: "waiting", code: "1234") }
    let(:user) { User.create(game: game) }
    let(:message) { Message.create(role: "User", text: "23", user: user, game: game) }

    context "when a game is waiting" do
      it "informs the user" do
        game.handle_status(message)

        expect(user.messages.last.text).to include("Waiting")
      end
    end

    context "when a game is finished" do
      it "informs the user" do
        game.update(status: "finished")

        game.handle_status(message)

        expect(user.messages.last.text).to include("over")
      end
    end

    context "when a game is finished" do
      it "informs the user" do
        game.update(status: "finished")

        game.handle_status(message)

        expect(user.messages.last.text).to include("over")
      end
    end

    context "when a game is playing" do
      it "makes a play" do
        game.update(status: "playing")

        expect(game).to receive(:play).with(message)

        game.handle_status(message)
      end
    end
  end
end
