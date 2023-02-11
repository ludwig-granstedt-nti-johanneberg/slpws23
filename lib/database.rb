require 'sqlite3'

MAIN_DATABASE = "db/main.db"

# TODO: Figure out why the program insists on creating a db/database.db file instead of opening db/main.db

def open_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    db
end

def get_user_data(user_id)
    db = open_db(MAIN_DATABASE)
    matches = db.execute("SELECT * FROM users WHERE id = ?", user_id)
    matches.first
end

def is_user?(user_id)
    db = open_db(MAIN_DATABASE)
    matches = db.execute("SELECT * FROM users WHERE id = ?", user_id)
    matches.length > 0
end