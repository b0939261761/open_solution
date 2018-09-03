# frozen_string_literal: true

class PostsController < ApplicationController
  def root; end

  # 1. Создать пост. Принимает заголовок и содержание поста (не могут быть пустыми),
  # а также логин и айпи автора. Если автора с таким логином еще нет, необходимо его создать.

  def create
    par = params.permit(:login, :ip, :title, :content)

    ip_format = /^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}(?:\-([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]))?$/

    schema = Dry::Validation.Schema do
      required(:login).filled(:str?, max_size?: 100)
      required(:ip).filled(:str?, format?: ip_format)
      required(:title).filled(:str?, max_size?: 254)
      required(:content).filled(:str?)
    end

    errors = schema.call(par).errors

    if errors.any?
      render json: { errors: errors }, status: 422
      return
    end

    sql = <<-SQL.squish
      WITH
        user_new AS (
          INSERT INTO users ( login ) VALUES ( '#{par[:login]}' )
            ON CONFLICT ( login )
              DO UPDATE SET login = EXCLUDED.login
            RETURNING id, login
        ),
        post_new AS (
          INSERT INTO posts (
            user_id,
            ip,
            title,
            content
          ) SELECT id,
                   '#{par[:ip]}',
                   '#{par[:title]}',
                   '#{par[:content]}'
            FROM user_new
          RETURNING id, ip, title, content
        )
      SELECT aa.id AS user_id,
             aa.login,
             bb.id AS post_id,
             bb.ip,
             bb.title,
             bb.content
        FROM user_new aa, post_new bb
    SQL

    begin
      post = JSON.parse(ActiveRecord::Base.connection.execute(sql).to_json, symbolize_names: true)[0]
    rescue ActiveRecord::StatementInvalid => invalid
      render json: { errors: { db: invalid } }, status: 422
      return
    end

    render json: post
  end

  # 3. Получить топ N постов по среднему рейтингу.
  # Просто массив объектов с заголовками и содержанием.
  def top_posts
    par = params.permit(:count)

    schema = Dry::Validation.Schema do
      required(:count).filled(:int?, gteq?: 1, lteq?: 50)
    end

    errors = schema.call(par).errors

    if errors.any?
      render json: { errors: errors }, status: 422
      return
    end

    posts = Post.select(:title, :content)
                .order(rating_avg: :desc)
                .limit(par[:count] || 5)
                .to_json(except: :id)
    render json: posts
  end

  # 4. Получить список айпи, с которых постило несколько разных авторов.
  # Массив объектов с полями: айпи и массив логинов авторов

  def ip_has_several_users
    sql = <<-SQL.squish
      SELECT aa.ip,
             bb.login
      FROM (
      SELECT ip,
             user_id,
             COUNT(*) OVER (PARTITION BY ip) AS count
        FROM posts
          GROUP BY ip, user_id
      ) aa
      LEFT JOIN users bb ON bb.id = aa.user_id
      WHERE count > 1
      ORDER BY aa.ip,
               bb.login
    SQL

    begin
      list = JSON.parse(ActiveRecord::Base.connection.execute(sql).to_json, symbolize_names: true)
    rescue ActiveRecord::StatementInvalid => invalid
      render json: { errors: { db: invalid } }, status: 422
      return
    end

    render json: {
      ips: list.map { |o| o[:ip] }.uniq.sort,
      logins: list.map { |o| o[:login] }.uniq.sort
    }
  end
end
