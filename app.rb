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

    def get_all_pokemon
        db = open_db(MAIN_DATABASE)
        db.execute("SELECT * FROM PokemonSpecies")
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

before '/admin/*' do
    redirect '/forbidden' unless logged_in?(request) && Account.is_admin?(@user["id"])
end

get '/admin/users' do
    slim :'admin/users', locals: {
        title: 'Manage users',
        users: Account.get_all_users()
    }
end

post '/admin/generate_default_images' do
    Account.get_all_users().each do |user|
        ProfilePicture.generate_default(user["id"])
    end

    redirect '/admin/manage_users'
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

get '/teams/create' do
    slim :'teams/create', locals: {
        title: 'Create team'
    }
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

get '/forbidden' do
    status 403
    slim :forbidden, locals: {
        title: 'Permission denied'
    }
end

not_found do
    status 404
    slim :not_found, locals: {
        title: 'Not found'
    } 
end