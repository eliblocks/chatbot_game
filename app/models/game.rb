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
end
