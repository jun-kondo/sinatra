# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'erb'
require 'cgi'
require 'securerandom'

DB_FILE = 'memo_db.json'
MEMO_DATA = { 'memos' => [] }.to_json.freeze
data = FileTest.exist?(DB_FILE) ? JSON.load_file(DB_FILE) : File.write(DB_FILE, MEMO_DATA)
memos = data['memos']

helpers do
  def link_to(text, url)
    "<a href=#{url}>#{text}</a>"
  end
end

get '/' do
  redirect 'memos'
end

get '/memos' do
  @memos = memos
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  memo = Hash.new([])
  memo['id'] = SecureRandom.uuid
  write_memo(memo, params)
  memos << memo
  save(data)
  redirect '/memos'
end

get '/memos/:id' do
  @memo = search_memo(memos)
  erb :show
end

get '/memos/:id/edit' do
  @memo = search_memo(memos)
  erb :edit
end

patch '/memos/:id' do
  memo = search_memo(memos)
  write_memo(memo, params)
  save(data)
  redirect "/memos/#{memo['id']}"
end

delete '/memos/:id' do
  memos.reject! { |memo| memo['id'] == params[:id] }
  save(data)
  redirect '/memos'
end

private

def write_memo(memo, params)
  memo['title'] = CGI.escape_html(params[:title])
  memo['body'] = CGI.escape_html(params[:body])
end

def search_memo(memos)
  memos.find { |m| m['id'] == params[:id] }
end

def save(data)
  File.write(DB_FILE, JSON.pretty_generate(data))
end
