require 'sinatra'
require 'sinatra/reloader'

get '/memos' do
  erb :index
end
