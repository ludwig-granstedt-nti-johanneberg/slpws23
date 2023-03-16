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