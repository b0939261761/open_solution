# frozen_string_literal: true

Rails.application.routes.draw do
  root action: :root, controller: :posts

  post :create_post, controller: :posts, action: :create
  get :ip_has_several_users, controller: :posts
  post :top_posts, controller: :posts

  post :set_rating, controller: :ratings, action: :create
end
