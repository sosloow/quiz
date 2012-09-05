require 'data_mapper'
require 'dm-paperclip'

class Track
  include DataMapper::Resource
  include Paperclip::Resource

  property :id, Serial
  property :title, String, required: true
  property :file, String, required: true, length: 15..100
  property :difficulty, String
  property :played, Integer, default: 0
  property :guessed, Integer, default: 0
  property :reported, Boolean, default: false

  has_attached_file :cover, storage: 's3', s3_credentials: "#{File.dirname(__FILE__)}/config/s3.yml"
  has_attached_file :track, storage: 's3', s3_credentials: "#{File.dirname(__FILE__)}/config/s3.yml"

  has n, :tags, through: Resource

  def guess? title
    result = !title.match(/#{self.title}/i).nil?
    result.to_s
  end
  
  def has_tag(tag_name)
    unless self.tags.include?(Tag.first(name: tag_name))
      self.tags << Tag.first_or_create(name: tag_name)
      self.save
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

end

class Tag
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :type, String

  has n, :tracks, through: Resource
end
