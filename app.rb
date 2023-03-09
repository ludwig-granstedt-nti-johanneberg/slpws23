require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'slim'

require './lib/database.rb'
require './lib/user.rb'

ADMIN_PASSWORD = 'AsfaltsoppaMedKorvOchHjortronsylt'

enable :sessions

set :slim, :pretty => true

helpers do
    def is_logged_in?
        logged_in?(request)
    end

    def get_teams(user)
        db = open_db(MAIN_DATABASE)
        db.execute("SELECT * FROM Teams WHERE user_id = ?", user["id"])
    end

    def get_team_pokemon(team)
        db = open_db(MAIN_DATABASE)
        db.execute("SELECT * FROM TeamPokemon INNER JOIN PokemonSpecies ON TeamPokemon.species_id = PokemonSpecies.id WHERE TeamPokemon.team_id = ?", team["id"])
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

    result, reason = Account.signup(response, params["username"], params["password"], params["email"])
    
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
    pass unless Account.exists?(username, false)

    user = Account.get_data(username, false)

    slim :'profile/index', layout: :'layouts/profile', locals: {
        title: username,
        profile: user,
    }
end

not_found do
    status 404
    slim :not_found, locals: {
        title: '404'
    } 
end