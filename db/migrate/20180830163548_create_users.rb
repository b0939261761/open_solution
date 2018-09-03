# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, comment: 'Пользователи' do |t|
      t.string :login, limit: 100, default: '', null: false, comment: 'Имя пользователя'
      t.index :login, unique: true
    end
  end
end
