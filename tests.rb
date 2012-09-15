require 'minitest/autorun'
require 'rack/test'
require './app'


DataMapper.setup(:default, "sqlite::memory:")

class TestModels < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def setup
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

  def test_player_can_guess
    @player.guessed @track
    assert User.get(@player.id).tracks.any?, 'user has not been linked'
    assert Track.get(@track.id).users.any?, 'track has not been linked'
  end

  def test_tags
    assert Tag.first(name: 'la')
  end

  def test_tagging
    @track.has_tag @tag.name
    assert Track.get(@track.id).tags, 'track has not been linked'
    assert_equal Track.get(@track.id).tags.first.name, 'la'
    assert Tag.get(@tag.id).tracks.any?, 'tag has not been linked'
  end

  def test_authentication
    assert_equal User.authenticate('la', 'lalala'), @player.id, 'auth failed'
  end

  def test_user_is_destroyed_properly
    @player.guessed @track
    user_id = @player.id
    track_id = @track.id
    @player.destroy
    refute User.get(user_id), 'player wasnt destroyed'
    assert Track.get(track_id), 'track was destroyed. zisisbad'
    assert Track.get(@track.id).users.empty?, 'hanging relations are left'
  end

  def test_track_is_destroyed_properly
    @track.has_tag @tag
    tag_id = @tag.id
    track_id = @track.id
    @track.destroy
    refute Track.get(track_id), 'track wasnt destroyed'
    assert Tag.get(tag_id), 'tag was destroyed. zisisbad'
    assert TagTrack.all(track: track_id).empty?, 'hanging relations are left'
    assert Tag.get(@track.id).tracks.empty?, 'hanging relations are left'
  end

  def test_user_saves_answers_from_session
    @player.guessed_many [@track.id]
    assert @player.tracks.any?, 'answers has not been saved'
  end
end

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
  
  def test_ajax_match_should_save_to_session_if_not_logged_in
    post '/ajax/match/', {id: @track.id.to_s, title: 'la'}
    assert_equal 'true', last_response.body
    assert_equal [1], session[:answered]
  end

  def test_ajax_match_should_save_to_db_if_logged_in
    User.authenticate(@player.login, 'lalala')
    post '/ajax/match/', {id: @track.id.to_s, title: 'la'}
    assert_equal 'true', last_response.body
    refute @player.tracks.nil?, 'link has not been saved'
  end

  def test_answered_session_should_be_transferred_to_db_on_reg
    User.all.destroy
    post '/ajax/match/', {id: @track.id.to_s, title: 'la'}
    post '/register/', {email: 'la@la.la', login: 'lal', pwd: 'lalala', pwd2: 'lalala'}
    assert User.first(login: 'lal'), 'user has not been created'
    assert User.first.tracks.any?, 'links has not been saved'
  end
  
end

