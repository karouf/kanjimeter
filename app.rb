require 'sinatra'
require 'sinatra/activerecord'
require 'httparty'

require_relative 'models/page'
require_relative 'models/user'
require_relative 'lib/kanjinator/analyzer'

enable :sessions

before do
  protected! if %w(admin).include? request.path_info.split('/')[1]
  pass if %w(auth authed).include? request.path_info.split('/')[1]
  if current_user
    pass
  else
    if request.cookies.has_key? 'kanjinator'
      if current_user = User.find_by_apikey(request.cookies['kanjinator'])
        pass
      else
        redirect '/auth'
      end
    else
      redirect '/auth'
    end
  end
end

helpers do
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_user=(user)
    @current_user = user
    session[:user_id] = user.nil? ? user : user.id
  end

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
  api_response = HTTParty.get("https://www.wanikani.com/api/user/#{params[:apikey]}/kanji")
  if api_response.code == 200
    user = User.new

    json = JSON.parse(api_response.body)

    user.apikey = params[:apikey]
    user.name = json['user_information']['username']

    known = []
    json['requested_information'].each do |item|
      if item['user_specific'] && %w(guru master enlightened burned).include?(item['user_specific']['srs'])
        known << item['character']
      end
    end
    user.kanji = known.join

    if user.save
      response.set_cookie('kanjinator', {
          :expires => Time.now + 3600 * 24 * 30,
          :value => params['apikey'],
          :path => '/'
        })
      redirect '/'
    else
      erb :auth
    end
  else
    erb :auth
  end
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
    @page.kanji = Kanjinator::Analyzer.new(params['url']).kanji
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
