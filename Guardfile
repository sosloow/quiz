guard 'minitest', test_folders: 'test', test_file_patterns: '*_test.rb' do
  ENV['RACK_ENV'] = 'test'
  watch(%r|^test/(.*)\/?(.*)\.rb|)
  watch(%r|^app/(.*)\.rb|) { 'test' }
end

notification :emacs