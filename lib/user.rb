require 'jwt'
require 'bcrypt'
require 'sinatra'

require './lib/database.rb'
require './lib/image.rb'

# The secret used to sign the session tokens. This should not be stored like this, but it's fine for now.
HMAC_SECRET = "pasta-carbonara-with-hamburger-dressing"

# This method is used to check if a user is logged in
#
# @param request [Sinatra::Request] The request object
# @return [Boolean] True if the user is logged in, false otherwise
def logged_in?(request)
    # Get session token from headers
    token = request.cookies["session_token"]
    return false if token == nil

    payload, reason = SessionToken.validate_token(token)
    return false if payload == nil

    true
end

# This module contains methods that handle account related stuff, such as login, logout and signup
module Account
    # The maximum number of login attempts a user can have before their account is locked
    MAX_LOGIN_ATTEMPTS = 5

    # The number of seconds a user has to wait before they can try to login again
    COOLDOWN_SECONDS = 60

    # This method is used to log in a user
    #
    # @param response [Sinatra::Response] The response object
    # @param username [String] The username of the user
    # @param password [String] The password of the user
    # @param remember_me [Boolean] Whether or not the user wants to be remembered
    # @return [Array] An array containing the session token and an error message. The session token is nil if an error occured and the error message is nil if no error occured. Both cannot be nil at the same time.
    def Account.login(response, username, password_digest, remember_me)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE username = ?", username)
        p matches

        return [nil, "User doesn't exist"] if matches.length == 0

        user = matches.first
        if BCrypt::Password.new(user["password_digest"]) != password_digest
            db.execute("UPDATE Users SET login_attempts = login_attempts + 1, last_failed_login = ? WHERE id = ?", Time.now.to_i, user["id"])

            failed_attempts = db.execute("SELECT COUNT(*) FROM Users WHERE id = ? AND last_failed_login > ?", user["id"], Time.now.to_i - COOLDOWN_SECONDS).first["COUNT(*)"]

            if failed_attempts >= MAX_LOGIN_ATTEMPTS
                db.execute("UPDATE Users SET locked = 1 WHERE id = ?", user["id"])
                return [nil, "Account locked. Please try again later."]
            end


            return [nil, "Wrong password"]
        end

        db.execute("UPDATE Users SET login_attempts = 0, last_failed_login = NULL WHERE id = ?", user["id"])

        result, reason = SessionToken.generate_token(username, remember_me)
        return [nil, reason] if result == nil

        token = result

        response.set_cookie("session_token", token)

        [token, nil]
    end

    # This method is used to log out a user
    #
    # @param response [Sinatra::Response] The response object
    # @param token [String] The session token of the user
    def Account.logout(response, token)
        SessionToken.delete_token(token)
        response.delete_cookie("session_token")
    end
    
    # This method is used to sign up a user
    #
    # @param response [Sinatra::Response] The response object
    # @param username [String] The username of the user
    # @param password [String] The password of the user
    # @param email [String] The email of the user
    # @return [Array] An array containing the session token and an error message. The session token is nil if an error occured and the error message is nil if no error occured. Both cannot be nil at the same time.
    def Account.signup(response, username, password_digest, email)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE username = ?", username)

        return [nil, "User already exists"] if matches.length > 0

        password_digest = BCrypt::Password.create(password_digest)

        db.execute("INSERT INTO Users (username, password_digest, email) VALUES (?, ?, ?)", username, password_digest, email)

        user = db.execute("SELECT id FROM Users WHERE username = ?", username).first

        ProfilePicture.generate_default(user["id"])
        
        result, reason = SessionToken.generate_token(username, false)
        return [nil, reason] if result == nil

        token = result

        response.set_cookie("session_token", token)

        [token, nil]
    end

    # This method is used to check if a user exists
    #
    # @param username [String] The username of the user
    # @param case_sensitive [Boolean] Whether or not the username should be case sensitive
    # @return [Boolean] True if the user exists, false otherwise
    def Account.exists?(username, case_sensitive = true)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE username = ?#{" COLLATE NOCASE" if !case_sensitive};", username)

        matches.length > 0
    end

    # This method is used to get the data of a user
    #
    # @param username [String] The username of the user
    # @param case_sensitive [Boolean] Whether or not the username should be case sensitive
    # @return [Hash] The data of the user
    def Account.get_data(username, case_sensitive = true)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE username = ?#{" COLLATE NOCASE" if !case_sensitive};", username)

        return nil if matches.length == 0

        matches.first
    end

    # This method is used to get the data of a user by their id
    #
    # @param id [Integer] The id of the user
    # @return [Hash] The data of the user
    def Account.get_data_by_id(id)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE id = ?;", id)
        
        return nil if matches.length == 0

        matches.first
    end

    # This method is used to check wheather a specific user has admin privileges
    #
    # @param id [Integer] The id of the user
    # @return [Boolean] True if the user has admin privileges, false otherwise
    def Account.is_admin?(id)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE id = ? AND is_admin = 1;", id)

        matches.length > 0
    end

    # This method is used to get all users stored in the database
    #
    # @return [Array] An array containing all users
    def Account.get_all_users
        db = open_db(MAIN_DATABASE)
        db.execute("SELECT * FROM Users;")
    end

    # This method works similary to the login method, but it doesn't set a cookie and instead just checks wheater or not the credentials are correct
    #
    # @param username [String] The username of the user
    # @param password [String] The password of the user
    # @return [Array] An array containing a boolean and an error message. The boolean is true if the credentials are correct, false otherwise. The error message is nil if no error occured.
    def Account.validate_credentials(username, password_digest)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE username = ?", username)

        return [nil, "User doesn't exist"] if matches.length == 0

        user = matches.first

        return [nil, "Incorrect password"] if BCrypt::Password.new(user["password_digest"]) != password_digest
    
        [true, nil]
    end

    # This method is used to update the password of a user
    #
    # @param username [String] The current username of the user
    # @param password [String] The new password of the user
    # @return [Array] An array containing a boolean and an error message. The boolean is true if the password was updated successfully. The error message is nil if no error occured.
    def Account.update_password(id, password)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE id = ?", id)

        return [nil, "User doesn't exist"] if matches.length == 0

        password_digest = BCrypt::Password.create(password)

        db.execute("UPDATE Users SET password_digest = ? WHERE id = ?", password_digest, id)

        [true, nil]
    end

    # This method is used to update the username and email of a user
    #
    # @param id [Integer] The id of the user
    # @param username [String] The new username of the user
    # @param email [String] The new email of the user
    # @return [Array] An array containing a boolean and an error message. The boolean is true if the information was updated successfully. The error message is nil if no error occured.
    def Account.update_information(id, username, email)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE username = ?", username)

        return [nil, "User already exists"] if matches.length > 0

        matches = db.execute("SELECT * FROM Users WHERE id = ?", id)

        user = matches.first

        ProfilePicture.rename(user["username"], username)

        db.execute("UPDATE Users SET username = ?, email = ? WHERE id = ?", username, email, id)


        [true, nil]
    end

    # This method is used to delete a user
    #
    # @param id [Integer] The id of the user
    # @return [Array] An array containing a boolean and an error message. The boolean is true if the user was deleted successfully. The error message is nil if no error occured.
    def Account.delete_user(id)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE id = ?", id)

        return [nil, "User doesn't exist"] if matches.length == 0

        user = matches.first

        ProfilePicture.delete(user["username"])

        db.execute("DELETE FROM Users WHERE id = ?", id)

        [true, nil]
    end
end

# This module contains methods related to session tokens, such as generating and validating them.
module SessionToken
    # This method is used to validate a session token. It checks if the token is stored in the database and if it has expired. It then decrpyts the token and returns the payload stored within.
    #
    # @param token [String] The token to validate
    # @return [Array] An array containing a hash and an error message. The hash contains the decrypted payload of the token. The error message is nil if no error occured.
    def SessionToken.validate_token(token)
        payload = JWT.decode token, HMAC_SECRET, true, { algorithm: 'HS256' }
        payload = payload.first

        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM SessionTokens INNER JOIN Users ON SessionTokens.user_id = Users.id WHERE SessionTokens.token = ?", token)

        return [nil, "Invalid token"] if matches.length == 0

        user = matches.first

        return [nil, "Token has expired"] if user["expiration_date"] != nil && user["expiration_date"] < Time.now.to_i

        [payload, nil]
    end

    # This method is used to generate a session token. The token is stored in the database and is used to authenticate the user.
    #
    # @param username [String] The username of the user
    # @param remember_me [Boolean] Whether or not the token should expire
    # @return [Array] An array containing a string and an error message. The string is the token if it was generated successfully. The error message is nil if no error occured.
    def SessionToken.generate_token(username, remember_me)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE username = ?", username)

        return [nil, "User doesn't exist"] if matches.length == 0

        user = matches.first
        user_id = user["id"]

        timestamp = Time.now.to_i

        payload = {
            'user_id' => user_id,
            'timestamp' => timestamp
        }

        token = JWT.encode payload, HMAC_SECRET, 'HS256'

        expiration = nil
        expiration = Time.now.to_i + 60 * 60 * 24 unless remember_me

        db.execute("INSERT INTO SessionTokens (token, user_id, expiration_date) VALUES (?, ?, ?)", token, user_id, expiration)

        [token, nil]
    end

    # This method is used to delete a session token. It is used when the user logs out. It removes the token from the database.
    #
    # @param token [String] The token to delete
    def SessionToken.delete_token(token)
        db = open_db(MAIN_DATABASE)
        db.execute("DELETE FROM SessionTokens WHERE token = ?", token)
    end
end