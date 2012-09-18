require 'data_mapper'
require 'rake/testtask'
require "#{File.dirname(__FILE__)}/app/models"

task :default do
  puts "Available tasks:"
  Rake.application.options.show_tasks = true
  Rake.application.options.full_description = false
  Rake.application.options.show_task_pattern = //
  Rake.application.display_tasks_and_comments
end

Rake::TestTask.new do |t|
  ENV['RACK_ENV'] = 'test'
  t.libs = ["app"]
  t.test_files = FileList['test/*.rb']
  t.verbose = true
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

