# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'erb'
require 'cgi'
require 'securerandom'

DB_FILE = 'json/memo_db.json'
MEMO_DATA = { 'memos' => [] }.to_json.freeze
File.write(DB_FILE, MEMO_DATA) unless FileTest.exist?(DB_FILE)

helpers do
  def link_to(text, url)
    "<a href=#{url}>#{text}</a>"
  end
end

get '/' do
  redirect 'memos'
end

get '/memos' do
  @memos = JSON.load_file(DB_FILE)['memos']
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  data = JSON.load_file(DB_FILE)
  memo = Hash.new([])
  memo['id'] = SecureRandom.uuid
  write_memo(memo, params)
  data['memos'] << memo
  save(data)
  redirect '/memos'
end

get '/memos/:id' do
  data = JSON.load_file(DB_FILE)
  @memo = search_memo(data)
  erb :show
end

get '/memos/:id/edit' do
  data = JSON.load_file(DB_FILE)
  @memo = search_memo(data)
  erb :edit
end

patch '/memos/:id' do
  data = JSON.load_file(DB_FILE)
  memo = search_memo(data)
  write_memo(memo, params)
  save(data)
  redirect "/memos/#{memo['id']}"
end

delete '/memos/:id' do
  data = JSON.load_file(DB_FILE)
  data['memos'].reject! { |memo| memo['id'] == params[:id] }
  save(data)
  redirect '/memos'
end

private

def write_memo(memo, params)
  memo['title'] = params[:title]
  memo['body'] = params[:body]
end

def search_memo(data)
  data['memos'].find { |m| m['id'] == params[:id] }
end

def save(data)
  File.write(DB_FILE, JSON.pretty_generate(data))
end
