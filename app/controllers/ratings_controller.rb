# frozen_string_literal: true

class RatingsController < ApplicationController
  # 2. Поставить оценку посту. Принимает айди поста и значение,
  # возвращает новый средний рейтинг поста. Важно: экшен должен корректно
  # отрабатывать при любом количестве конкурентных запросов на оценку одного и того же поста.

  def create
    par = params.permit(:post_id, :rating)

    schema = Dry::Validation.Schema do
      required(:post_id).filled(:int?)
      required(:rating).filled(:int?, gteq?: 1, lteq?: 5)
    end

    errors = schema.call(par).errors

    if errors.any?
      render json: { errors: errors }, status: 422
      return
    end

    # Вычисления среднего рейтинга реализовано через тригер базы
    sql_posts = <<-SQL.squish
      UPDATE posts SET
        rating_sum = rating_sum + #{par[:rating]}
      WHERE id = #{par[:post_id]}
      RETURNING id, rating_sum, rating_count, rating_avg
    SQL

    begin
      post = JSON.parse(ActiveRecord::Base.connection.execute(sql_posts).to_json, symbolize_names: true)[0]
    rescue ActiveRecord::StatementInvalid => invalid
      render json: { errors: { db: invalid } }, status: 422
      return
    end

    unless post
      render json: { error: 'POST NOT EXISTS' }, status: 422
      return
    end

    Rating.create(post_id: par[:post_id], rating: par[:rating])
    render json: { rating_avg: post[:rating_avg] }
  end
end
