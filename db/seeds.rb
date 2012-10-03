require 'data_mapper'
require "#{Dir.pwd}/app/models"
require 'yaml'

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/dev.db")
DataMapper.finalize

pass = open("#{Dir.pwd}/config/config.yml", 'r'){ |yf| YAML::load(yf) }["admin_password"]
admin = User.register(login: 'admin', email: 'admin@site.com', pwd: pass, pwd2: pass)
admin.admin = true
admin.save
