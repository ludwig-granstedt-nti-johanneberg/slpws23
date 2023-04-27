require "./lib/database.rb"

module Move
    def Move.add_move(name, type, category, power, accuracy, pp, effect)
        db = open_db(MAIN_DATABASE)

        db.execute("INSERT INTO Moves (type_id, category, name, power, accuracy, pp, effect) VALUES (?, ?, ?, ?, ?, ?, ?);", type, category, name, power, accuracy, pp, effect)
    end
end