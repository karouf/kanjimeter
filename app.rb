require 'sinatra'

enable :sessions

before do
  pass if %w(auth authed).include? request.path_info.split('/')[1]
  if request.cookies.has_key? 'kanjinator'
    pass
  else
    redirect '/auth'
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
