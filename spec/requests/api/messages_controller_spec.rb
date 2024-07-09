require "rails_helper"

RSpec.describe Api::MessagesController do
  describe "#create" do
    it "creates a message", :vcr do
      params = {
        message: {
          from: {
            id: "12345"
          },
          text: "/create"
        }
      }

      post api_messages_path, params: params

      expect(response).to be_successful
      expect(Message.first.text).to eq("/create")
      expect(User.count).to eq(1)
      expect(Game.count).to eq(1)
      expect(Message.count).to eq(2)
    end
  end
end
