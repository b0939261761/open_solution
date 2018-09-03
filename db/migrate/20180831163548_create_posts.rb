# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts, comment: 'Посты' do |t|
      t.belongs_to :user, foreign_key: { on_delete: :cascade }, null: false, comment: 'Пользователь'
      t.inet :ip, null: false, comment: 'IP-адресс'
      t.string :title, limit: 254, null: false, comment: 'Заголовок'
      t.text :content, null: false, comment: 'Содержимое'
      t.integer :rating_sum, default: 0, comment: 'Сумма всех оценок'
      t.integer :rating_count, default: 0, comment: 'Количество всех оценок'
      t.decimal :rating_avg, precision: 4, scale: 2, default: 0, comment: 'Количество всех оценок'

      t.index :ip
    end

    reversible do |direction|
      direction.up do
        execute <<-SQL
          CREATE OR REPLACE FUNCTION posts_rating_avg() RETURNS trigger AS $$
            BEGIN
              NEW.rating_count := OLD.rating_count + 1;
              NEW.rating_avg := ROUND(NEW.rating_sum / NEW.rating_count::numeric, 2);
              RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;


          CREATE TRIGGER posts_rating_avg
            BEFORE UPDATE OF rating_sum ON posts
              FOR EACH ROW EXECUTE PROCEDURE posts_rating_avg()
        SQL
      end

      direction.down do
        execute <<-SQL
          DROP FUNCTION IF EXISTS posts_rating_avg() CASCADE;
        SQL
      end
    end
  end
end
