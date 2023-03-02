require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'slim'

require './lib/db.rb'
require './lib/user.rb'

enable :sessions

helpers do
    def logged_in?
        session[:token] != nil
    end
end

restricted_paths = [
    '/',
    '/logout',
]

# TODO: Maybe switch from checking restricted paths to checking allowed paths
before do
    pass if !restricted_paths.include?(request.path_info)
    redirect '/welcome' unless logged_in?
end

get '/' do
    # TODO: fetch user data from database
    slim :index, locals: {
        user: nil,
        title: 'Home'
    }
end

get '/welcome' do
    # TODO: fetch user data from database
    slim :welcome, locals: {
        user: nil,
        title: 'Welcome'
    }
end

get '/login' do
    
end

post '/login' do

end

get '/signup' do

end

post '/signup' do

end

post '/logout' do

end

get '/search' do
    
end

get '/userdata/*' do

end

get '/:username' do

    # temporary botch while I don't have access to the commits containing the account system
    @user = {
        "username" => params[:username],
        "id" => 1
    }

    profile = {
        "username" => params[:username],
        "id" => 1
    }

    slim :profile, layout: :'layouts/profile', locals: {
        profile: profile,
        title: profile[:username]
    }

end