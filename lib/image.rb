require 'digest/md5'
require 'fileutils'
require 'down'

require './lib/database.rb'

# This module is used for generating and managing profile pictures.
module ProfilePicture
    # This method generates a default profile picture for a user. It uses the md5 hash of the user's email address to generate a Gravatar profile picture. It then saves the image to the public/images/profile directory under the username of the user.
    #
    # @param user_id [Integer] The ID of the user to generate a profile picture for.
    def ProfilePicture.generate_default(user_id)
        db = open_db(MAIN_DATABASE)

        user = db.execute("SELECT * FROM Users WHERE id = ?", user_id).first

        hash = Digest::MD5.hexdigest(user["email"])

        tempfile = Down.download("https://www.gravatar.com/avatar/#{hash}?s=280&d=identicon");
        FileUtils.cp(tempfile.path, "public/images/profile/#{user["username"].downcase}.jpg")
    end

    # This method changes the name of a profile picture. It takes the old name of the profile picture and the new name of the profile picture and renames the file in the public/images/profile directory.
    #
    # @param old_name [String] The old name of the profile picture.
    # @param new_name [String] The new name of the profile picture.
    def ProfilePicture.rename(old_name, new_name)
        FileUtils.mv("public/images/profile/#{old_name.downcase}.jpg", "public/images/profile/#{new_name.downcase}.jpg")
    end

    # This method deletes a profile picture. It takes the name of the profile picture and deletes the file in the public/images/profile directory.
    #
    # @param name [String] The name of the profile picture.
    def ProfilePicture.delete(name)
        FileUtils.rm("public/images/profile/#{name.downcase}.jpg")
    end
end

# This module is used for managing sprites. It mainly contains methods used for locating a sprite on a spritesheet and to encode and decode the sprite's location.
module Sprite
    # This method decodes a sprite's location on a spritesheet. It takes the raw location of the sprite and the width of the spritesheet and returns the x and y coordinates of the sprite.
    #
    # @param raw [Integer] The raw location of the sprite stored in the database.
    # @param width [Integer] The width of the spritesheet in pixels.
    # @return [Array<Integer>] An array containing the x and y coordinates of the sprite.
    def Sprite.decode_cartesian(raw, width)
        x = raw % width
        y = raw / width

        [x, y]
    end
    
    # This method encodes a sprite's location on a spritesheet. It takes the x and y coordinates of the sprite and the width of the spritesheet and returns a single number to store in the database.
    #
    # @param x [Integer] The x coordinate of the sprite.
    # @param y [Integer] The y coordinate of the sprite.
    # @param width [Integer] The width of the spritesheet in pixels.
    # @return [Integer] The raw location of the sprite to store in the database.
    def Sprite.encode_cartesian(x, y, width)
        x + y * width
    end
    
    # The number of pokemons per row on the Pokemon spritesheet.
    POKEMON_ROW_LENGTH = 12
    # The size of a Pokemon sprite in pixels on the Pokemon spritesheet.
    POKEMON_SPRITE_SIZE = 40

    # This method decodes a Pokemon sprite's location on the Pokemon spritesheet. It takes the raw location of the sprite and returns the x and y coordinates of the sprite.
    #
    # @param raw [Integer] The raw location of the sprite stored in the database.
    # @return [Array<Integer>] An array containing the x and y coordinates of the sprite.
    def Sprite.decode_pokemon_sprite(raw)
        x, y = Sprite.decode_cartesian(raw, POKEMON_ROW_LENGTH)

        x *= POKEMON_SPRITE_SIZE
        y *= POKEMON_SPRITE_SIZE
        
        [x, y]
    end
end
