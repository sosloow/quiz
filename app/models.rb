require 'data_mapper'
require 'dm-paperclip'
require 'digest'

Paperclip.configure do |config|
  config.use_dm_validations = true
end

class Track
  include DataMapper::Resource
  include Paperclip::Resource

  property :id, Serial
  property :title, String, required: true
  property :difficulty, String
  property :played, Integer, default: 0
  property :guessed, Integer, default: 0
  property :reported, Boolean, default: false
  property :created_at, DateTime

  has_attached_file(:cover, storage: 's3',
                    s3_credentials: "#{File.expand_path('config/s3.yml')}",
                    path: ":class/:id/:style.:extension",
                    styles: {small: '300x300>' })
  has_attached_file(:track, storage: 's3',
                    s3_credentials: "#{File.expand_path('config/s3.yml')}",
                    path: ":class/:id/:style.:extension")

  # validates_attachment_presence :track, :cover
  # validates_attachment_content_type :cover, content_type: ["image/jpeg", "image/png", "image/jpg", "image/gif"]
  # validates_attachment_size :cover, in: 1..500000
  # validates_attachment_content_type :track, content_type: ["audio/mp3", 'audio/mpeg']
  # validates_attachment_size :track, in: 1..4000000
  # validates_attachment_thumbnails :cover

  has n, :tags, through: Resource, constraint: :skip
  has n, :users, through: Resource, constraint: :skip

  def guess? title
    !title.match(/#{self.title}/i).nil?
  end
  
  def has_tag(tag_name)
    unless self.tags.include?(Tag.first(name: tag_name))
      self.tags << Tag.first_or_create(name: tag_name)
    end
    
  end

  def has_many_tags(string)
    new_tags = string.split(' ')
    new_tags.each do |tag|
      self.has_tag tag
    end
    
    self.tags.each do |tag|
      unless new_tags.include? tag.name
        TagTrack.get(self.id,tag.id).destroy
      end
    end
    self.save
  end

  def tags_string
    self.tags.map{ |tag| tag.name }.join(' ')
  end

  def collected?(bowser_id, session_answered=[])
    session_answered ||= []
    bowser_id ||= 0
    users = TrackUser.all(track: self).map{ |tu| tu.user.id }
    session_answered.include?(self.id) ||
      users.include?(bowser_id)
  end

end


class Tag
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :type, String

  has n, :tracks, through: Resource, constraint: :skip
end


class User
  include DataMapper::Resource

  property :id, Serial
  property :login, String, required: true, unique: true
  property :email, String, required: true, unique: true, format: :email_address
  property :hashed_password, String, length: 256
  property :salt, String
  property :created_at, DateTime
  property :admin, Boolean, default: false

  has n, :tracks, through: Resource, constraint: :skip


  def guessed(new_track)
    unless self.tracks.include?(new_track)
      self.tracks << new_track
      self.save!
    end
  end

  def guessed_many tracks_ids
    unless tracks_ids.nil?
      tracks_ids.each do |track_id|
        self.guessed Track.get(track_id)
      end
    end  
  end
  

  class << self

    def authenticate(login, password)
      user = User.first(login: login)
      return nil if user.nil?
      return user if (Digest::SHA256.new << (password + user.salt)) == user.hashed_password
    end

    def register(*args)
      args = args[0]
      if args[:pwd] == args[:pwd2] && args[:pwd].size > 5
        new_user = User.new
        new_user.login = args[:login]
        new_user.salt = Array.new(5){ rand(10) }.join
        new_user.hashed_password = Digest::SHA256.new << (args[:pwd] + new_user.salt)
        new_user.email = args[:email]
        new_user.save
        new_user
      end
    end
  end

end
