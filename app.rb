include 'sinatra'
include 'sinatra/reloader' if development?
include 'sqlite3'

enable :sessions

get '/' do

end