require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require './lib/db.rb'
require './lib/user.rb'

enable :sessions

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
        user: session[:user_id]
    }
end

get '/welcome' do
    
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

get '/:username' do
    # TODO: Match path against database

    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    matches = db.execute("SELECT * FROM users WHERE username = ?", params[:username])

    if matches.length == 0
        redirect '/'
    end

    match = matches.first

    slim :profile, locals: {

    }

end

get '/search' do
    
end

get '/userdata/*' do

end