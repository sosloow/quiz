source :rubygems

gem 'sinatra'
gem 'thin'
gem 'data_mapper'
gem 'haml'
gem 'sass'
gem 'rdiscount'
gem 'coffee-script'
gem 'dm-sqlite-adapter'
gem 'dm-paperclip', git: 'git://github.com/sosloow/dm-paperclip.git'
gem 'aws-s3'
gem 'json'

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end

group :development do
  gem 'guard'
  gem 'libnotify'
	gem 'rb-inotify'
	gem 'guard-minitest'
end

group :test do
  gem 'rack-test'
end