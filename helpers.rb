module Sinatra::Helpers
  
  def login_dropbox
    unless box.session
      redirect box.get_ready
    end
    unless box.client
      box.get_access_token
    end
  end

end
