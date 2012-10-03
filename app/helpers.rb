require 'digest'
require 'fileutils'

module Sinatra::Helpers

  def partial(template, *args)
    template_array = template.to_s.split('/')
    template = template_array[0..-2].join('/') + "/_#{template_array[-1]}"
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.merge!(:layout => false)
    locals = options[:locals] || {}
    if collection = options.delete(:collection) then
      collection.inject([]) do |buffer, member|
        buffer << haml(:"#{template}", options.merge(:layout =>
        false, :locals => {template_array[-1].to_sym => member}.merge(locals)))
      end.join("\n")
    else
      haml(:"#{template}", options)
    end
  end

  def random_numbers len
    Array.new(len){ rand(10) }.join
  end

  def encrypt pass, salt
    Digest::SHA256.new << (salt + pass)
  end

  def admin?
    session[:admin]
  end

  def login?
    session[:user]
  end
  
  def protected!
    unless admin? || login?
      session[:flash] = 'access denied!'
      redirect '/'
    end
  end

  def admin_protected!
    unless admin?
      session[:flash] = 'access denied!'
      redirect '/'
    end
  end

  def flash_errors instance
    errors = []
    session[:flash] = "Cannot save the #{instance.class}:<br/>"
    instance.errors.each { |e, _| errors << e }
    session[:flash] += errors.join('<br/>')
  end

  def checkbox checkbox_value
    true if checkbox_value == 'on'
  end

  def shorter_track(file, length=15, start_time='00:00')
    output_path = "#{File.dirname(file)}/output.mp3"
    min, sec = start_time.split(':').map{ |s| s.to_i }
    end_time = "#{min+length/60}:#{sec+(sec+length)%60}"
    `(mp3cut -o #{output_path} -t #{start_time}-#{end_time} #{file.path}) > /dev/null 2>&1`
    output_file = open(output_path, 'rb')
  end

  def replace_long_audio file_hash, folder 
    input_mp3 = open("#{folder}/input.mp3", 'wb')
    input_mp3.write file_hash[:tempfile].read
    file_hash[:tempfile].close
    file_hash[:tempfile] = shorter_track input_mp3
    input_mp3.close
    file_hash
  end
  
  def tmp_folder folder_name
    folder_name.gsub!(' ', '_')
    folder_path = "#{Dir.pwd}/tmp/#{folder_name}"
    FileUtils.rm_rf folder_path if File.exists? folder_path
    Dir.mkdir folder_path
    yield folder_path
    FileUtils.rm_rf folder_path
  end

end
