# frozen_string_literal: true

require 'faker'
require 'net/http'

logins = []
100.times { logins << Faker::Name.name }

ips = []
50.times { ips << Faker::Internet.ip_v4_address }

200_000.times do
  body_post = {
    login: logins[rand(0..100)],
    ip: ips[rand(0..50)],
    title: Faker::Lorem.sentence,
    content: Faker::Lorem.paragraph
  }

  host = "http://app:#{ENV['PORT']}/"
  header = { 'Content-Type' => 'application/json' }
  response = Net::HTTP.post(URI("#{host}create_post"), body_post.to_json, header)
  post = JSON.parse(response.body, symbolize_names: true)

  rand(1..5).times do
    body_raiting = {
      post_id: post[:post_id],
      rating: rand(1..5)
    }
    Net::HTTP.post(URI("#{host}set_raiting"), body_raiting.to_json, header)
  end
end
