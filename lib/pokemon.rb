require "./lib/database.rb"
require "./lib/image.rb"

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
            species["sprite_x"], species["sprite_y"] = Sprite.decode_pokemon_sprite(species["sprite"])
        end

        matches
    end

    # TODO: Add documentation
    def Pokemon.get_type(id)
        db = open_db(MAIN_DATABASE)

        type = db.execute("SELECT * FROM Types WHERE id = ?;", id).first

        type["weaknesses"] = db.execute("SELECT Types.name, Types.id FROM Types INNER JOIN \"Types-Weaknesses\" ON Types.id = \"Types-Weaknesses\".weakness WHERE \"Types-Weaknesses\".type = ?;", type["id"])
        type["resistances"] = db.execute("SELECT Types.name, Types.id FROM Types INNER JOIN \"Types-Resistances\" ON Types.id = \"Types-Resistances\".resistance WHERE \"Types-Resistances\".type = ?;", type["id"])
        type["immunities"] = db.execute("SELECT Types.name, Types.id FROM Types INNER JOIN \"Types-Immunities\" ON Types.id = \"Types-Immunities\".immunity WHERE \"Types-Immunities\".type = ?;", type["id"])

        type
    end

    # TODO: Add documentation
    def Pokemon.get_all_types
        db = open_db(MAIN_DATABASE)

        types = db.execute("SELECT * FROM Types;")

        types.each do |type|
            type["weaknesses"] = db.execute("SELECT Types.name, Types.id FROM Types INNER JOIN \"Types-Weaknesses\" ON Types.id = \"Types-Weaknesses\".weakness WHERE \"Types-Weaknesses\".type = ?;", type["id"])
            type["resistances"] = db.execute("SELECT Types.name, Types.id FROM Types INNER JOIN \"Types-Resistances\" ON Types.id = \"Types-Resistances\".resistance WHERE \"Types-Resistances\".type = ?;", type["id"])
            type["immunities"] = db.execute("SELECT Types.name, Types.id FROM Types INNER JOIN \"Types-Immunities\" ON Types.id = \"Types-Immunities\".immunity WHERE \"Types-Immunities\".type = ?;", type["id"])
        end

        types
    end

    # TODO: Add documentation
    def Pokemon.get_all_moves
        db = open_db(MAIN_DATABASE)

        db.execute("SELECT * FROM Moves;")
    end

    # TODO: Add documentation
    def Pokemon.get_all_abilities
        db = open_db(MAIN_DATABASE)

        db.execute("SELECT * FROM Abilities;")
    end
end