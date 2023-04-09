require 'digest/md5'
require 'fileutils'
require 'down'

require './lib/database.rb'

module ProfilePicture
    def ProfilePicture.generate_default(user_id)
        db = open_db(MAIN_DATABASE)

        user = db.execute("SELECT * FROM Users WHERE id = ?", user_id).first

        hash = Digest::MD5.hexdigest(user["email"])

        tempfile = Down.download("https://www.gravatar.com/avatar/#{hash}?s=280&d=identicon");
        FileUtils.cp(tempfile.path, "public/images/profile/#{user["username"].downcase}.jpg")
    end
end

module Sprite
    def Sprite.decode_cartesian(raw, width)
        x = raw % width
        y = raw / width

        [x, y]
    end
    
    def Sprite.encode_cartesian(x, y, width)
        x + y * width
    end
    
    POKEMON_ROW_LENGTH = 12
    POKEMON_SPRITE_SIZE = 40

    def Sprite.decode_pokemon_sprite(raw)
        x, y = Sprite.decode_cartesian(raw, POKEMON_ROW_LENGTH)

        x *= POKEMON_SPRITE_SIZE
        y *= POKEMON_SPRITE_SIZE
        
        [x, y]
    end
end
