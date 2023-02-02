require 'sqlite3'

MAIN_DATABASE = "db/database.db"

def open_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    db
end

def get_user_data(user_id)
    db = open_db('db/database.db')
    matches = db.execute("SELECT * FROM users WHERE id = ?", user_id)
    matches.first
end