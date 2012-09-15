require 'sinatra/base'
require 'haml'
require 'coffee-script'
require './models'


class App < Sinatra::Base

  helpers Sinatra::Helpers
  use Rack::MethodOverride
  enable :sessions
  disable :show_exceptions
  set :protection, :except => :remote_token 
  set :haml, {:format => :html5 }

  def login?
    # session[:user]
  end
  
#  DataMapper::Logger.new($stdout, :debug) unless test?
  DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/dev.db")
  DataMapper.finalize


  get '/' do
    redirect '/play/'
  end

  get '/register/' do
    haml :'users/register'
  end

  post '/register/' do
    user = User.create email: params[:email], login: params[:login]
    user.password = params[:pwd]
    user.password_confirmation = params[:pwd2]
    
    if user.save
      session[:user] = user.id
      user.guessed_many session[:answered]
      redirect '/'
    else
      flash_errors user
      redirect back
    end
  end

  get '/logout/' do
    session[:user] = nil
    redirect back
  end

  get '/login/' do
    haml :'users/login'
  end

  post '/login/' do
    if session[:user] = User.authenticate(params[:login], params[:pwd])
      session[:flash] = "Login successful"
      redirect '/'
    else
      session[:flash] = "Login failed - Try again"
      redirect back
    end
  end


  get '/tracks/new/' do
    haml :'tracks/new'
  end

  post '/tracks/new/' do
    track = Track.new
    track.title = params[:title]
    track.cover = params[:cover]
    track.track = params[:track]
    track.has_many_tags params[:tags]
    track.created_at = Time.now
    puts track.errors.inspect unless track.save
    
    redirect '/'
  end

  get '/tracks/' do
    haml :'tracks/index'
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
    track = Track.get(id).destroy
    redirect '/'
  end

  get '/play/' do
    @tracks = Track.all
    haml :play
  end

  post '/ajax/match/' do
    track_id = params[:id].to_i
    track = Track.get(track_id)
    if track.guess? params[:title]
      if login?
        User.get(session[:user]).guessed track
      else
        session[:answered] ||= []
        session[:answered] << track_id
      end
      'true'
    else
      'false'
    end
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

  get '/' do
    redirect
  end

  run! if app_file == $0

end
