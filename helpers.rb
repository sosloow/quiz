require 'digest'

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
  
  def protected!
    unless admin? || session[:user]
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

end
