require 'minitest/autorun'
require './app'

class TestModels < MiniTest::Unit::TestCase

  def setup
    DataMapper.setup(:default, "sqlite::memory:")
    DataMapper.auto_migrate!
    DataMapper.finalize
    @player = User.new
    @player.login = 'la'
    @player.email = 'la@la.la'
    @player.password = 'lalala'
    @player.password_confirmation = 'lalala'
    @player.errors.each {|e| puts e} unless @player.save
    @track = Track.new
    @track.title = 'la'
    @track.errors.each {|e| puts e} unless @track.save
    @tag = Tag.new
    @tag.name = 'la'
    @tag.errors.each {|e| puts e} unless @tag.save
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
    assert Track.get(@track.id).users.empty?, 'hanging relations is left'
  end

  def test_track_is_destroyed_properly
    @track.has_tag @tag
    tag_id = @tag.id
    track_id = @track.id
    @track.destroy
    refute Track.get(track_id), 'track wasnt destroyed'
    assert Tag.get(tag_id), 'tag was destroyed. zisisbad'
    assert TagTrack.all(track: track_id).empty?, 'hanging relations is left'
    assert Tag.get(@track.id).tracks.empty?, 'hanging relations is left'
  end

end
