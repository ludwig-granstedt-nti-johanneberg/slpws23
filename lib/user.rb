require 'jwt'
require 'bcrypt'

HMAC_SECRET = "pasta-carbonara-with-hamburger-dressing"

def logged_in?()
    session[:user_id] != nil
end

module User
    # TODO: Move token stuff to logged_in? and simply check username and password
    def login(has_token = false, map = nil)
        if has_token
            token = map["token"]
            payload = validate_token(token)
            username = payload["username"]
            timestamp = payload["timestamp"]
        else
            username = map["username"]
            password = map["password"]

            password_digest = BCrypt::Password.new(get_user_data(username)["password-digest"])


        end
    end
    
    def signup(username, password)
        # TODO: Check against database and add if user doesn't exitst
    end
    

    def validate_token(token)
        payload = JWT.decode token, HMAC_SECRET, true, { algorithm: 'HS256' }
        payload = payload.first

        return nil unless !payload["timestamp"].is_nil? && !payload["username"].is_nil?

        payload
    end
    
    def generate_token(username)
        timestamp = Time.now.to_i
        payload = { username: username, timestamp: timestamp }

        token = JWT.encode payload, HMAC_SECRET, 'HS256'

        token
    end
end