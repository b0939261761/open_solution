# frozen_string_literal: true

require 'test_helper.rb'

class RatingsControllerTest < ActionDispatch::IntegrationTest
  test 'create valid rating' do
    body = { post_id: 2, rating: 5 }

    post '/set_rating', params: body, as: :json
    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)
    assert_equal json_response[:rating_avg].to_f, 3
  end

  test 'create invalid rating - not exists post' do
    body = { post_id: 22, rating: 5 }

    post '/set_rating', params: body, as: :json
    assert_response 422
  end

  test 'create invalid rating - rating is invalid ' do
    body = { post_id: 1, rating: 15 }

    post '/set_rating', params: body, as: :json
    assert_response 422
  end
end
