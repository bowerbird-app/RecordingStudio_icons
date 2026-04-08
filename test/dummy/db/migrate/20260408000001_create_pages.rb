class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages, id: :uuid do |t|
      t.references :workspace, null: false, type: :uuid, foreign_key: true
      t.references :folder, null: true, type: :uuid, foreign_key: true
      t.string :title, null: false

      t.timestamps
    end
  end
end