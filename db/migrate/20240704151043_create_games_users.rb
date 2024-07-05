class CreateGamesUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :games_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true

      t.timestamps

      t.index [ :user_id, :game_id ], unique: true
    end
  end
end