require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'slim'

require './lib/db.rb'
require './lib/user.rb'

enable :sessions

set :slim, :layout => :'layouts/default'

helpers do
end

restricted_paths = [
    '/',
    '/logout',
]

# TODO: Revrite with regex
before do
    pass if !restricted_paths.include?(request.path_info)
    redirect '/welcome' unless logged_in?
end

get '/' do
    slim :index, locals: {
        user_id: session[:user_id]
    }
end

get '/welcome' do
    slim :welcome, locals: {
        user: session[:user_id],
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

before '/:username/*' do
    pass if !is_user(params[:username])
end

get '/:username' do
    
    user = get_user_data(params[:username])

    slim :profile, locals: {
        user: user,
    }

end