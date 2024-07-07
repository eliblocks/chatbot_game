class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :telegram_id
      t.references :game, foreign_key: true

      t.timestamps
    end
  end
end
