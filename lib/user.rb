require 'jwt'
require 'bcrypt'
require 'sinatra'

require './lib/database.rb'

HMAC_SECRET = "pasta-carbonara-with-hamburger-dressing"

def logged_in?(request)
    # Get session token from headers
    token = request.cookies["session_token"]
    return false if token == nil

    payload, reason = SessionToken.validate_token(token)
    return false if payload == nil

    true
end

module Account
    def Account.login(response, username, password, remember_me)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE username = ?", username)
        p matches

        return [nil, "User doesn't exist"] if matches.length == 0

        user = matches.first
        return [nil, "Incorrect password"] if BCrypt::Password.new(user["password_digest"]) != password

        result, reason = SessionToken.generate_token(username, remember_me)
        return [nil, reason] if result == nil

        token = result

        response.set_cookie("session_token", token)

        [token, nil]
    end

    def Account.logout(response, token)
        SessionToken.delete_token(token)
        response.delete_cookie("session_token")
    end
    
    def Account.signup(response, username, password)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE username = ?", username)

        return [nil, "User already exists"] if matches.length > 0

        password = BCrypt::Password.create(password)

        db.execute("INSERT INTO Users (username, password_digest) VALUES (?, ?)", username, password)
        
        result, reason = SessionToken.generate_token(username, false)
        return [nil, reason] if result == nil

        token = result

        response.set_cookie("session_token", token)

        [token, nil]
    end

    def Account.exists?(username)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE username = ?", username)

        matches.length > 0
    end
end

module SessionToken
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

    def SessionToken.delete_token(token)
        db = open_db(MAIN_DATABASE)
        db.execute("DELETE FROM SessionTokens WHERE token = ?", token)
    end
end