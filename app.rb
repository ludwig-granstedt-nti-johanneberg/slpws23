require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'slim'

require './lib/database.rb'
require './lib/user.rb'

ADMIN_PASSWORD = 'AsfaltsoppaMedKorvOchHjortronsylt'

enable :sessions

<<<<<<< HEAD
=======
set :slim, :pretty => true

>>>>>>> 70fd92b395ce1c83e56a2cb51bd481d813b2dea2
helpers do
    def logged_in?
        session[:token] != nil
    end
end

RESTRICTED_PATHS = [
    '/welcome',
    '/logout',
]

before /#{RESTRICTED_PATHS.map{|str| "(#{str})"}.join('|')}/ do
    redirect '/' unless logged_in?(request)
end

before do
    pass unless logged_in?(request)

    token, reason = SessionToken.validate_token(request.cookies["session_token"])

    if reason == "Token expired"
        SessionToken.delete_token(request.cookies["session_token"])
        response.delete_cookie("session_token")
        redirect '/'
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
    slim :index, locals: {
        title: 'Home'
    }
end

get '/welcome' do
    slim :welcome, locals: {
        title: 'Welcome'
    }
end

get '/signin' do
    slim :signin, :layout => :'layouts/account', locals: {
        title: 'Sign in',
        error: params["error"]
    }
end

post '/signin' do
    result, reason = Account.login(response, params["username"], params["password"], params["remember_me"] == "true")
    
    if result == nil
        redirect '/signin?error=' + reason
    end

    redirect '/'
end

get '/signup' do
    slim :signup, :layout => :'layouts/account', locals: {
        title: 'Sign up',
        error: params["error"]
    }
end

post '/signup' do
    # TODO: Add email field to database

    result, reason = Account.signup(response, params["username"], params["password"])
    
    if result == nil
        redirect '/signup?error=' + reason
    end

    redirect '/'
end

get '/logout' do
    Account.logout(response, request.cookies["session_token"])

    redirect '/'
end

get '/search' do
    # TODO: Implement search function
end

get '/userdata/*' do
    # TODO: Match this agianst database for user

    404
end

get '/404' do
    slim :not_found, locals: {
        title: '404'
    }
end

get '/:username' do |username|
    pass unless Account.exists?(username)

    user = get_user_data(username)

    slim :profile, layout: :'layouts/profile', locals: {
        title: username,
        user: user,
    }
end

not_found do
    status 404
    slim :not_found, locals: {
        title: '404'
    } 
end