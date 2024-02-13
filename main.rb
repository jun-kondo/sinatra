# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'erb'
require 'cgi'

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
  File.write 'memos.json', json_data.to_json
  redirect '/memos'
end

get '/memos/:id' do
  @memo = memos.find { |memo| memo['id'] == params[:id] }
  erb :show
end

get '/memos/:id/edit' do
  memo = memos.find { |memo| memo['id'] == params[:id] }
  @id = memo['id']
  @title = memo['title']
  @body = memo['body']
  erb :edit
end

patch '/memos/:id' do
  memo = memos.find { |memo| memo['id'] == params[:id] }
  memo['title'] = CGI.escape_html(params[:title])
  memo['body'] = CGI.escape_html(params[:body])
  File.write 'memos.json', json_data.to_json
  redirect "/memos/#{memo['id']}"
end

delete '/memos/:id' do
  memos.reject! { |memo| memo['id'] == params[:id] }
  File.write 'memos.json', json_data.to_json
  redirect '/memos'
end
