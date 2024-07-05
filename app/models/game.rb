class Game < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :messages, dependent: :destroy

  validates :status, inclusion: [ "waiting", "playing", "finished" ]

  scope :active, -> { where(status: [ "waiting", "playing" ]) }

  def initiate
    users.each do |user|
      Message.create(role: "assistant", text: "Lets Play!", user: user).send_to_user
    end
  end

  def play(message)
    if status == "waiting"
      message.user.reply("Waiting for more players (#{users.count}/4)")
    elsif status == "finished"
      message.user.reply("This game is already over")
    elsif status == "playing"
      message.user.reply("Try again")
    end
  end
end
