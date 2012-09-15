require 'data_mapper'
require './models'

task :default do
  puts "Available tasks:"
  Rake.application.options.show_tasks = true
  Rake.application.options.full_description = false
  Rake.application.options.show_task_pattern = //
  Rake.application.display_tasks_and_comments
end

task :test do
  ruby './tests.rb'
end

namespace :db do

  desc 'run all migrations'
  task :migrate do
		DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/dev.db")
    DataMapper.auto_migrate!
		DataMapper.finalize
  end

  desc 'upgrade DB'
  task :upgrade do
		DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/dev.db")
    DataMapper.auto_upgrade!
		DataMapper.finalize
  end

  desc 'seed DB'
  task :seed do
    ruby 'db/seeds.rb'
  end

end

