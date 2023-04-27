require "./lib/database.rb"

module Type
    def Type.update_weakness(type_id, weakness_id, method)
        db = open_db(MAIN_DATABASE)

        case method
        when :add
            db.execute("INSERT INTO \"Types-Weaknesses\" (type, weakness) VALUES (?, ?);", type_id, weakness_id)
        when :remove
            db.execute("DELETE FROM \"Types-Weaknesses\" WHERE type = ? AND weakness = ?;", type_id, weakness_id)
        end
    end

    def Type.update_resistance(type_id, resistance_id, method)
        db = open_db(MAIN_DATABASE)

        case method
        when :add
            db.execute("INSERT INTO \"Types-Resistances\" (type, resistance) VALUES (?, ?);", type_id, resistance_id)
        when :remove
            db.execute("DELETE FROM \"Types-Resistances\" WHERE type = ? AND resistance = ?;", type_id, resistance_id)
        end
    end

    def Type.update_immunity(type_id, immunity_id, method)
        db = open_db(MAIN_DATABASE)

        case method
        when :add
            db.execute("INSERT INTO \"Types-Immunities\" (type, immunity) VALUES (?, ?);", type_id, immunity_id)
        when :remove
            db.execute("DELETE FROM \"Types-Immunities\" WHERE type = ? AND immunity = ?;", type_id, immunity_id)
        end
    end
end