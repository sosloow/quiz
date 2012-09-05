require 'sinatra'
require 'haml'
require 'coffee-script'
require './models'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/dev.db")
DataMapper.finalize

Paperclip.configure do |config|
  config.root = settings.root 
  config.env = settings.environment 
  config.use_dm_validations = true       
end

helpers Sinatra::Helpers
use Rack::MethodOverride

get '/' do
  redirect '/play/'
end

get '/tracks/new/' do
  haml :'tracks/new'
end

post '/tracks/new/' do
  track = Track.new(title: params[:title], file: path)
  track.cover = params[:cover]
  track.track = params[:track]
  track.has_many_tags params[:tags]
  track.save
  
  redirect '/'
end

get '/tracks/:id/edit/' do |id|
  @track = Track.get(id)
  haml :'tracks/edit'
end

post '/tracks/:id/edit/' do |id|
  track = Track.get(id)
  track.title ||= params[:title]
  track.has_many_tags params[:tags]

  redirect '/'
end

get '/tracks/:id/' do |id|
  @track = Track.get(id)
  haml :'tracks/show'
end

delete '/tracks/:id/' do |id|
  track = Track.get(id)
  path = "public#{track.file}"
  File.delete(path) if File.exists?(path)
  TagTrack.all(track: track).destroy
  track.destroy
  redirect '/'
end

get '/play/' do
  @tracks = Track.all
  haml :play
end

get '/ajax/match/' do
  track_id = params[:id].match(/\d/).to_s.to_i
  Track.get(track_id).guess? params[:title]
end

post '/ajax/loadcards/' do
  @cards = Track.all.shuffle
  haml :cards, layout: false
end

post '/ajax/loadtrack/' do
  @track = Track.get params[:id]
  haml :track_panel, layout: false
end

get '/js/main.js' do
  coffee :main
end

get %r{(.*[^\/]$)} do
  redirect "#{params[:captures].first}/"
end
