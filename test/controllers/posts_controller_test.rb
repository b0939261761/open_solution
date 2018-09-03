# frozen_string_literal: true

require 'test_helper.rb'

class PostsControllerTest < ActionDispatch::IntegrationTest
  test 'create valid post' do
    body = {
      login: 'Test1',
      title: 'Some title',
      content: 'Some content',
      ip: '192.168.0.1'
    }

    post '/create_post', params: body, as: :json
    assert_response :success
  end

  test 'create invalid post' do
    body = {
      login: 'Test1',
      title: 'Some title',
      content: 'Some content',
      ip: 'invalid'
    }

    post '/create_post', params: body, as: :json
    assert_response 422
  end

  test 'valid get top posts' do
    count = 2
    body = { count: count }

    post '/top_posts', params: body, as: :json
    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_equal json_response.size, 2
    assert_equal json_response[0][:title], 'Test 2'
  end

  test 'invalid get top posts' do
    count = 2
    body = { count: count }

    post '/top_posts', params: body, as: :json

    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_not_equal json_response.size, 1
    assert_not_equal json_response[0][:title], 'Test 1'
  end

  test 'list api has several users post' do
    get '/ip_has_several_users'

    json_response = JSON.parse(response.body, symbolize_names: true)
    assert_response :success

    ips = json_response[:ips]
    logins = json_response[:logins]
    assert_kind_of Array, ips
    assert_kind_of Array, logins

    assert_equal ips.size, 1
    assert_equal logins.size, 2
  end
end
