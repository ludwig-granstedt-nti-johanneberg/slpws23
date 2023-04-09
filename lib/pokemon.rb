require "./lib/database.rb"

# Path: lib\pokemon.rb

# This module contains all the methods for interacting with the Pokemon related tables in the database.
module Pokemon
    # This method gets a Pokemon species from the database. It also gets the types, moves, and abilities associated with the species.
    #
    # @param id [Integer] The ID of the Pokemon species to get.
    def Pokemon.get_species(id)
        db = open_db(MAIN_DATABASE)

        species = db.execute("SELECT * FROM PokemonSpecies WHERE id = ?;", id).first
        species["types"] = db.execute("SELECT Types.name, Types.id FROM Types INNER JOIN \"PokemonSpecies-Types\" ON Types.id = \"PokemonSpecies-Types\".type WHERE \"PokemonSpecies-Types\".species = ?;", species["id"])
        species["moves"] = db.execute("SELECT Moves.name, Moves.id FROM Moves INNER JOIN \"PokemonSpecies-Moves\" ON Moves.id = \"PokemonSpecies-Moves\".move WHERE \"PokemonSpecies-Moves\".species = ?;", species["id"])
        species["abilities"] = db.execute("SELECT Abilities.name, Abilities.id FROM Abilities INNER JOIN \"PokemonSpecies-Abilities\" ON Abilities.id = \"PokemonSpecies-Abilities\".ability WHERE \"PokemonSpecies-Abilities\".species = ?;", species["id"])

        species
    end

    # This method gets all the Pokemon species from the database. It also gets the types, moves, and abilities associated with each species.
    #
    # @return [Array<Hash>] An array of hashes containing all the Pokemon species.
    def Pokemon.get_all_species()
        db = open_db(MAIN_DATABASE)

        matches = db.execute("SELECT * FROM PokemonSpecies;")
        matches.each do |species|
            species["types"] = db.execute("SELECT Types.name, Types.id FROM Types INNER JOIN \"PokemonSpecies-Types\" ON Types.id = \"PokemonSpecies-Types\".type WHERE \"PokemonSpecies-Types\".species = ?;", species["id"])
            species["moves"] = db.execute("SELECT Moves.name, Moves.id FROM Moves INNER JOIN \"PokemonSpecies-Moves\" ON Moves.id = \"PokemonSpecies-Moves\".move WHERE \"PokemonSpecies-Moves\".species = ?;", species["id"])
            species["abilities"] = db.execute("SELECT Abilities.name, Abilities.id FROM Abilities INNER JOIN \"PokemonSpecies-Abilities\" ON Abilities.id = \"PokemonSpecies-Abilities\".ability WHERE \"PokemonSpecies-Abilities\".species = ?;", species["id"])
        end

        matches
    end
end