require 'sinatra'
require 'sinatra/reloader'
require 'json'

json_data = File.open("memos.json", "r") do |f|
  JSON.load(f)
end
memos = json_data["memos"]

helpers do
  def link_to(text, url)
    "<a href=#{url}>#{text}"
  end
end

get '/memos' do
  @memos = memos
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  redirect '/memos'
  erb :new
end
