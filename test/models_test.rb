require 'minitest/autorun'
require "#{Dir.pwd}/app/models"

DataMapper.setup(:default, "sqlite::memory:")

class TestModels < MiniTest::Unit::TestCase

  def setup
    DataMapper.auto_migrate!
    DataMapper.finalize
    @player = User.new
    @player.login = 'la'
    @player.email = 'la@la.la'
    @player.salt = '123'
    @player.hashed_password = Digest::SHA256.new << ('lalala' + @player.salt)
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

  def test_guess_should_be_false_on_mismatch
    refute @track.guess?('ha-ha'), 'matched smth when shouldnt'
    assert @track.guess?('la'), 'nil when should match'
  end

  def test_tagging
    @track.has_tag @tag.name
    @track.save
    assert Track.get(@track.id).tags, 'track has not been linked'
    assert_equal Track.get(@track.id).tags.first.name, 'la'
    assert Tag.get(@tag.id).tracks.any?, 'tag has not been linked'
  end

  def test_authentication
    assert_equal User.authenticate('la', 'lalala'), @player, 'auth failed'
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
    @track1 = Track.new
    @track1.title = 'la'
    @track1.save
    @player.guessed_many [@track.id, @track1.id]
    assert @player.tracks.any?, 'answers has not been saved'
  end

  def test_user_can_be_registered
    User.register(login: 'blah', pwd: 'blahla', pwd2: 'blahla', email: 'blah@blah.com')
    assert User.all.any?, 'user has not been created'
  end

end
