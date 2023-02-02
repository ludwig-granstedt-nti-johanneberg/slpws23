def logged_in?()
    session[:user_id] != nil
end

def login(username, password)
    # TODO: Check against database
end

def signup(username, password)
    # TODO: Check against database and add if user doesn't exitst
end
