require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'slim'

require './lib/database.rb'
require './lib/user.rb'

ADMIN_PASSWORD = 'AsfaltsoppaMedKorvOchHjortronsylt'

enable :sessions

set :slim, :pretty => true

helpers do
end

RESTRICTED_PATHS = [
    '/welcome',
    '/logout',
]

before /#{RESTRICTED_PATHS.map{|str| "(#{str})"}.join('|')}/ do
    redirect '/' unless logged_in?
end

before do
    pass unless logged_in?(request)

    token, reason = SessionToken.validate_token(request.cookies["session_token"])

    if reason == "Token expired"
        SessionToken.delete_token(request.cookies["session_token"])
        response.delete_cookie("session_token")
        redirect '/login'
    end

    @user = get_user_data(token["user_id"])
end

if development?
    get '/autologin' do
        result, reason = Account.login(response, "Admin", ADMIN_PASSWORD, false)

        if result == nil
            return "Failed to login: #{reason}"
        end

        redirect '/'
    end
end

get '/' do
    # TODO: fetch user data from database
    slim :index, locals: {
        title: 'Home'
    }
end

get '/welcome' do
    # TODO: fetch user data from database
    slim :welcome, locals: {
        title: 'Welcome'
    }
end

get '/login' do
    slim :login, :layout => :'layouts/login', locals: {
        title: 'Login',
        user: nil
    }
    
end

post '/login' do

end

get '/signup' do

end

post '/signup' do

end

post '/logout' do
    Account.logout(response, request.cookies["session_token"])

    redirect '/'
end

get '/search' do
    
end

get '/userdata/*' do

end

before '/:username/*' do
    pass if Account.exists?(params[:username])
    redirect '/404'
end

get '/:username' do
    
    user = get_user_data(params[:username])

    slim :profile, locals: {
        title: params[:username],
        user: user,
    }
end

get '404' do
    body = slim :'not_found', locals: {
        title: '404'
    }

    [404, body]
end

not_found do
    redirect '/404'
end