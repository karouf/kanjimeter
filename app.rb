require 'sinatra'

enable :sessions

before do
  protected! if %w(admin).include? request.path_info.split('/')[1]
  pass if %w(auth authed).include? request.path_info.split('/')[1]
  if request.cookies.has_key? 'kanjinator'
    pass
  else
    redirect '/auth'
  end
end

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
  end
end

get '/' do
  "YO: #{request.cookies['kanjinator']}"
end

get '/auth' do
  erb :auth
end

post '/authed' do
  response.set_cookie('kanjinator', {
      :expires => Time.now + 2400,
      :value => params['apikey'],
      :path => '/'
    })
  redirect '/'
end

get '/admin' do
  'Admin area'
end
