require 'jwt'
require 'bcrypt'

HMAC_SECRET = "pasta-carbonara-with-hamburger-dressing"

def logged_in?()
    # Get session token from headers
    token = headers["Authorization"]

    return false if token == nil

    payload, rejection_reason = validate_token(token)

    return false if payload == nil

    true
end

module User
    def login(username, password, remember_me)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE username = ?", username)

        return nil, "User doesn't exist" if matches.length == 0

        user = matches.first

        return nil, "Incorrect password" if BCrypt::Password.new(user["password"]) != password

        token = generate_token(username)

        expiration_date = nil
        expiration_date = Time.now.to_i + 60 * 60 * 24 unless remember_me

        db.execute("INSERT INTO SessionTokens (token, user_id, expiration_date) VALUES (?, ?, ?)", token, user["id"], expiration_date)

        token
    end

    def logout(token)
        db = open_db(MAIN_DATABASE)
        db.execute("DELETE FROM SessionTokens WHERE token = ?", token)
    end
    
    def signup(username, password)
        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM Users WHERE username = ?", username)

        return nil, "User already exists" if matches.length > 0

        password = BCrypt::Password.create(password)

        db.execute("INSERT INTO Users (username, password_digest) VALUES (?, ?)", username, password)
    end
    

    def validate_token(token)
        payload = JWT.decode token, HMAC_SECRET, true, { algorithm: 'HS256' }
        payload = payload.first


        db = open_db(MAIN_DATABASE)
        matches = db.execute("SELECT * FROM SessionTokens INNER JOIN Users ON SessionTokens.user_id = Users.id WHERE SessionTokens.token = ?", token)

        return nil, "Invalid token" if matches.length == 0

        user = matches.first

        return nil, "Token has expired" if user["expiration_date"] != nil && user["expiration_date"] < Time.now.to_i

        payload, nil
    end
    
    def generate_token(username)
        timestamp = Time.now.to_i
        payload = { username: username, timestamp: timestamp }

        token = JWT.encode payload, HMAC_SECRET, 'HS256'

        token
    end
end