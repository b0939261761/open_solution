# frozen_string_literal: true

class CreateRatings < ActiveRecord::Migration[5.1]
  def change
    create_table :ratings, comment: 'Рейтинги' do |t|
      t.belongs_to :post, foreign_key: { on_delete: :cascade }, null: false, comment: 'Пост'
      t.integer :rating, limit: 1, null: false, default: 0, comment: 'Рейтинг'
    end
  end
end
