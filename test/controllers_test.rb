require 'minitest/autorun'
require 'rack/test'
require "#{Dir.pwd}/app/app"

DataMapper.setup(:default, "sqlite::memory:")

class TestControllers < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    App
  end

  def session 
    last_request.env['rack.session']
  end
  
  def setup
    App.set :environment, :test
    DataMapper.auto_migrate!
    DataMapper.finalize
    @player = User.new
    @player.login = 'la'
    @player.email = 'la@la.la'
    @player.password = 'lalala'
    @player.password_confirmation = 'lalala'
    @player.save
    @track = Track.new
    @track.title = 'la'
    @track.save
    @tag = Tag.new
    @tag.name = 'la'
    @tag.save
  end
  
  def test_ajax_match_should_return_false_on_mismatch
    post '/ajax/match/', {id: @track.id.to_s, title: 'ha-ha'}
    assert_equal 'false', last_response.body
    post '/ajax/match/', {id: @track.id.to_s, title: 'la'}
    urls = {audio: @track.track.url,
        cover_small: @track.cover.url(:small),
        cover_original: @track.cover.url(:original)}
    json = {urls: urls, track: JSON.parse(@track.to_json)}.to_json
    assert_equal json.to_s, last_response.body
  end
  
  def test_ajax_match_should_save_to_session_if_not_logged_in
    post '/ajax/match/', {id: @track.id.to_s, title: 'la'}
    assert_equal [1], session[:answered]
  end

  def test_ajax_match_should_save_to_db_if_logged_in
    User.authenticate(@player.login, 'lalala')
    post '/ajax/match/', {id: @track.id.to_s, title: 'la'}
    refute @player.tracks.nil?, 'link has not been saved'
  end

  def test_answered_session_should_be_transferred_to_db_on_reg
    User.all.destroy
    post '/ajax/match/', {id: @track.id.to_s, title: 'la'}
    post '/register/', {email: 'la@la.la', login: 'lal', pwd: 'lalala', pwd2: 'lalala'}
    assert User.first(login: 'lal'), 'user has not been created'
    assert User.first(login: 'lal').tracks.any?, 'links has not been saved'
  end

  def test_answered_session_should_be_transferred_to_db_on_login
    post '/ajax/match/', {id: @track.id.to_s, title: 'la'}
    post '/login/', {login: 'la', pwd: 'lalala'}
    refute session[:user].nil?, 'user has not been logged in'
    assert User.get(session[:user]).tracks.any?, 'links has not been saved'
  end

  def test_ajax_loadcards_should_be_ok
    post 'ajax/loadcards/'
    assert last_response.ok?, 'smth is not ok: #{last_response.status}'
  end
  
end

