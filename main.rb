# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'erb'
require 'cgi'
require 'debug'

# hashデータ メソッド化したい
json_data = JSON.load_file('memos.json')
memos = json_data['memos']

helpers do
  def link_to(text, url)
    "<a href=#{url}>#{text}</a>"
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
  last_memo = memos.last
  latest_id = last_memo['id'].to_i.succ
  new_memo = Hash.new([])
  new_memo['id'] = latest_id.to_s
  new_memo['title'] = CGI.escape_html(params[:title])
  new_memo['body'] = CGI.escape_html(params[:body])
  memos << new_memo
  save(json_data)
  redirect '/memos'
end

get '/memos/:id' do
  # @memo = memos.find { |m| m['id'] == params[:id] }
  @memo = search_memo(memos)
  erb :show
end

get '/memos/:id/edit' do
  # @memo = memos.find { |m| m['id'] == params[:id] }
  @memo = search_memo(memos)
  erb :edit
end

patch '/memos/:id' do
  # memo = memos.find { |m| m['id'] == params[:id] }
  memo = search_memo(memos)
  memo['title'] = CGI.escape_html(params[:title])
  memo['body'] = CGI.escape_html(params[:body])
  save(json_data)
  redirect "/memos/#{memo['id']}"
end

delete '/memos/:id' do
  memos.reject! { |memo| memo['id'] == params[:id] }
  save(json_data)
  redirect '/memos'
end

private

def search_memo(memos)
  memos.find { |m| m['id'] == params[:id] }
end

def save(json_data)
  File.write 'memos.json', json_data.to_json
end
