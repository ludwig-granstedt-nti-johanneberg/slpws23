require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'slim'
require 'rack/protection'

require './lib/database.rb'
require './lib/user.rb'
require './lib/pokemon.rb'
require './lib/image.rb'

ADMIN_PASSWORD = 'AsfaltsoppaMedKorvOchHjortronsylt'

enable :sessions

use Rack::Protection::AuthenticityToken
set :slim, :pretty => true

helpers do
    # This method checks if a user is logged in. It's a wrapper for the already existing method in the User module.
    #
    # @return [Boolean] True if the user is logged in, false otherwise.
    def is_logged_in?
        logged_in?(request)
    end

    # This method gets all the teams owned by a user.
    #
    # @param user [Hash] The user to get the teams for.
    # @return [Array<Hash>] An array of hashes containing all the teams.
    def get_teams(user)
        db = open_db(MAIN_DATABASE)
        db.execute("SELECT * FROM Teams WHERE user_id = ?", user["id"])
    end

    # This method gets all the Pokemon on a team.
    #
    # @param team [Hash] The team to get the Pokemon for.
    # @return [Array<Hash>] An array of hashes containing all the Pokemon.
    def get_team_pokemon(team)
        db = open_db(MAIN_DATABASE)
        db.execute("SELECT * FROM TeamPokemon INNER JOIN PokemonSpecies ON TeamPokemon.species_id = PokemonSpecies.id WHERE TeamPokemon.team_id = ?", team["id"])
    end

    # This method gets a list of all the Pokemon species. It also decodes the sprite data.
    #
    # @return [Array<Hash>] An array of hashes containing all the Pokemon species.
    # @see Sprite.decode_pokemon_sprite
    # @see Pokemon.get_all_species
    def get_all_pokemon
        pokemon = Pokemon.get_all_species()
        pokemon.each do |species|
            species["sprite_x"], species["sprite_y"] = Sprite.decode_pokemon_sprite(species["sprite"])
        end
    end
end

# An array of paths that are restricted to logged in users.
RESTRICTED_PATHS = [
    '/welcome',
    '/logout',
    '/settings*',
]

before /#{RESTRICTED_PATHS.map{|str| "(#{str})"}.join('|')}/ do
    redirect '/forbidden' unless logged_in?(request)
end

before do
    pass unless logged_in?(request)

    token, reason = SessionToken.validate_token(request.cookies["session_token"])

    if reason == "Token expired"
        SessionToken.delete_token(request.cookies["session_token"])
        response.delete_cookie("session_token")
        redirect '/'
    end

    if token == nil
        return "Failed to validate token: #{reason}"
    end

    @user = Account.get_data_by_id(token["user_id"])
end

if development?
    # This route is only available in development mode. It allows you to log in as the admin user without having to enter a password.
    get '/autologin' do
        result, reason = Account.login(response, "Admin", ADMIN_PASSWORD, false)

        if result == nil
            return "Failed to login: #{reason}"
        end

        redirect '/'
    end
end

# Displays the home page.
get '/' do
    slim :index, locals: {
        title: 'Home'
    }
end

# This before-filter is run before all routes that start with '/admin/*'. It checks if the user is logged in and if they are an admin. If they are not, they are redirected to the forbidden page.
before '/admin/*' do
    redirect '/forbidden' unless logged_in?(request) && Account.is_admin?(@user["id"])
end

# Displays the admin panel page where you can manage users. This gets all users from the database and passes them to the template.
# This route is only available to admins.
#
# @see Account.get_all_users
get '/admin/users' do
    slim :'admin/users', locals: {
        title: 'Manage users',
        users: Account.get_all_users()
    }
end

# Allows the admin to delete a user. This validates the authenticity token and then deletes the user.
# This route is only available to admins.
#
# @param id [String] The id of the user to delete.
# @see Account.delete_user
delete '/admin/user' do
    Account.delete_user(params["id"])
    redirect '/admin/users'
end

# Displays the admin panel page where you can manage pokemon species. This gets all pokemon species from the database and passes them to the template.
# This route is only available to admins.
get '/admin/pokemon/species' do
    slim :'admin/pokemon/species', locals: {
        title: 'Manage pokemon species',
        pokemon: get_all_pokemon()
    }
end

# Allows the admin to generate default profile pictures for all users. This is mostly a development tool as users should get default profile pictures when they register.
# This route is only available to admins.
#
# @see ProfilePicture.generate_default
post '/admin/generate_default_images' do
    Account.get_all_users().each do |user|
        ProfilePicture.generate_default(user["id"])
    end

    redirect '/admin/manage_users'
end

# Allows a user to update details about their profile. This validates the authenticity token and then updates the user's details.
# This route is only available to logged in users.
#
# @param username [String] The new username.
# @param email [String] The new email.
# @param authenticity_token [String] The authenticity token.
#
# @see SessionToken.validate_token
# @see Account.update
put '/account/update' do
    result, error = SessionToken.validate_token(request.cookies["session_token"])

    if result == nil
        redirect '/settings/account?error=' + error
    end

    Account.update_information(@user["id"], params["username"], params["email"])

    redirect '/settings/account'
end

# Allows a user to update their password. This validates the authenticity token and their entered password and then updates the user's password.
# This route is only available to logged in users.
#
# @param current_password [String] The user's current password.
# @param password [String] The new password.
# @param authenticity_token [String] The authenticity token.
#
# @see SessionToken.validate_token
# @see Account.validate_credentials
# @see Account.update_password
put '/account/update_password' do
    result, error = Account.validate_credentials(@user["username"], params["current_password"])

    if result == nil
        redirect '/settings/account?error=' + error
    end

    result, error = SessionToken.validate_token(request.cookies["session_token"])

    if result == nil
        redirect '/settings/account?error=' + error
    end

    Account.update_password(@user["id"], params["password"])

    redirect '/settings/account'
end

# Allows a user to delete their account. This validates the authenticity token and their entered password and then deletes the user's account.
# This route is only available to logged in users.
#
# @param username [String] The user's username.
# @param password-confirm [String] The user's password.
# @param authenticity_token [String] The authenticity token.
#
# @see SessionToken.validate_token
# @see Account.validate_credentials
# @see Account.logout
# @see Account.delete_user
delete '/account/delete' do
    result, error = Account.validate_credentials(@user["username"], params["password"])

    if result == nil
        redirect '/settings/account?error=' + error
    end

    result, error = SessionToken.validate_token(request.cookies["session_token"])

    if result == nil
        redirect '/settings/account?error=' + error
    end

    Account.delete_user(@user["id"])

    redirect '/'
end

# Displays the sign in page.
#
# @param error [String] The error message to display. This is mostly used when redirecting back after a failed sign in.
get '/signin' do
    slim :signin, :layout => :'layouts/account', locals: {
        title: 'Sign in',
        error: params["error"]
    }
end

# Allows a user to sign in. This validates the user's credentials and then logs them in.
# This route is only available to users who are not logged in.
#
# @param username [String] The user's username.
# @param password [String] The user's password.
# @param remember_me [Boolean] Whether or not to remember the user's session.
#
# @see Account.login
post '/signin' do
    result, reason = Account.login(response, params["username"], params["password"], params["remember_me"] == "true")
    
    if result == nil
        redirect '/signin?error=' + reason
    end

    redirect '/'
end

# Displays the sign up page.
#
# @param error [String] The error message to display. This is mostly used when redirecting back after a failed sign up.
get '/signup' do
    slim :signup, :layout => :'layouts/account', locals: {
        title: 'Sign up',
        error: params["error"]
    }
end

# Allows a user to sign up. This validates the user's credentials and then signs them up.
# This route is only available to users who are not logged in.
#
# @param username [String] The user's username.
# @param password [String] The user's password.
# @param email [String] The user's email.
#
# @see Account.signup
post '/signup' do
    result, reason = Account.signup(response, params["username"], params["password"], params["email"])
    
    if result == nil
        redirect '/signup?error=' + reason
    end

    redirect '/'
end

# Allows a user to sign out. This logs the user out.
# This route is only available to logged in users.
#
# @see Account.logout
get '/singout' do
    Account.logout(response, request.cookies["session_token"])

    redirect '/'
end

# Displays the account tab on the settings page.
# This route is only available to logged in users.
#
# @param error [String] The error message to display. This is mostly used when redirecting back after a failed update.
get '/settings/account' do
    slim :'settings/account', :layout => :'layouts/settings', locals: {
        title: 'Account settings',
        error: params["error"]
    }
end

# This is not yet implemented. This is meant to be a search function.
#
# @param q [String] The search query.
get '/search' do
    # TODO: Implement search function
end

# Displays the team creation page.
# This route is only available to logged in users.
get '/teams/create' do
    slim :'teams/create', locals: {
        title: 'Create team'
    }
end

# This is the profile page for a user. This displays the user's profile information and their teams. If the user does not exist, this will pass to the next matching route.
#
# @param username [String] The user's username.
#
# @see Account.exists?
# @see Account.get_data
get '/:username' do |username|
    pass unless Account.exists?(username, false)

    user = Account.get_data(username, false)

    slim :'profile/index', layout: :'layouts/profile', locals: {
        title: username,
        profile: user,
    }
end

# This is the page that is displayed when a user tries to access a page that they do not have permission to access.
get '/forbidden' do
    status 403
    slim :forbidden, locals: {
        title: 'Permission denied'
    }
end

# This is the page that is displayed when a user tries to access a page that does not exist.
not_found do
    status 404
    slim :not_found, locals: {
        title: 'Not found'
    } 
end