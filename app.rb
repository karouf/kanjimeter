require 'sinatra'
require 'sinatra/activerecord'
require 'httparty'

require_relative 'models/page'
require_relative 'models/user'
require_relative 'lib/kanjinator/analyzer'
require_relative 'lib/kanjinator/matcher'

before do
  protected! if %w(admin).include? request.path_info.split('/')[1]
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
  erb :index
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
    user.kanji = known

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
    @page = Kanjinator::Analyzer.analyze(params['url'])
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

post '/api/match' do
  content_type :json
  request.body.rewind
  json = JSON.parse(request.body.read)
  pages = Kanjinator::Matcher.match(json['kanji'].split(''), Page.all)
  pages.to_json
end
