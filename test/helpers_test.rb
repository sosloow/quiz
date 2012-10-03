require 'minitest/autorun'
require "#{Dir.pwd}/app/app"

class TestSinatraHelpers < MiniTest::Unit::TestCase

  include Sinatra::Helpers

  def test_shorter_track_should_cut
    longy = open("#{Dir.pwd}/tmp/input.mp3")
    shorty = shorter_track longy
    assert_equal "#{Dir.pwd}/tmp/output.mp3", shorty.path
    shorty.close
    longy.close
  end

  def test_tmp_folder_should_be_created_and_deleted
    tmp_folder('test test') do |folder_name|
      assert_equal "#{Dir.pwd}/tmp/test_test", folder_name
      assert File.exists?("#{Dir.pwd}/tmp/test_test"), "dir has not been created"
    end
    refute File.exists?("#{Dir.pwd}/tmp/test"), "dir has not been deleted"
  end

  def test_raplace_long_replaces
    tmp_folder('test') do |path|
      file = File.open("#{Dir.pwd}/tmp/input.mp3")
      hash = {tempfile: file}
      replace_long_audio hash, path
      assert_equal "#{Dir.pwd}/tmp/test/output.mp3", hash[:tempfile].path
      hash[:tempfile].close
    end
  end

end
