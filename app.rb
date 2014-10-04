require 'sinatra'
require 'sinatra/activerecord'
require_relative 'models/page'

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
      :expires => Time.now + 3600 * 24 * 30,
      :value => params['apikey'],
      :path => '/'
    })
  redirect '/'
end

get '/admin' do
  erb :'admin/index'
end

get '/admin/pages/new' do
  erb :'admin/pages/new'
end

post '/admin/pages/create' do
  if params['url'] =~ /\A#{URI::regexp(['http', 'https'])}\z/
    @page = Page.new
    @page.url = params['url']
    if @page.save
      redirect '/admin/pages'
    else
      erb :'admin/pages/new'
    end
  else
    erb :'admin/pages/new'
  end
end

get '/admin/pages' do
  @pages = Page.all
  erb :'admin/pages/index'
end
