require 'sqlite3'

# The path to the main database file.
MAIN_DATABASE = "db/main.db"

# This method opens a database and sets the results_as_hash option to true. It also enables foreign key support.
#
# @param path [String] The path to the database file.
# @return [SQLite3::Database] The database object.
def open_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    db.execute("PRAGMA foreign_keys = ON;")
    db
end