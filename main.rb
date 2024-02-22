# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'erb'
require 'cgi'
require 'securerandom'
require 'pg'

DB_NAME = 'memo_app'
TABLE_NAME = 'memo'
conn = PG::Connection.new(dbname: DB_NAME)
conn.exec("CREATE TABLE IF NOT EXISTS memo(
            id CHAR(36) NOT NULL,
            title VARCHAR(100) NOT NULL,
            body VARCHAR(1000),
            PRIMARY KEY (id));")
conn.close

helpers do
  def link_to(text, url)
    "<a href=#{url}>#{text}</a>"
  end
end

get '/' do
  redirect 'memos'
end

get '/memos' do
  conn = PG::Connection.new(dbname: DB_NAME)
  @memos = conn.exec("SELECT * FROM #{TABLE_NAME};").to_a
  conn.close
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  id = SecureRandom.uuid
  conn = PG::Connection.new(dbname: DB_NAME)
  conn.exec_params("INSERT INTO #{TABLE_NAME} VALUES($1, $2, $3);", [id, params['title'], params['body']])
  conn.close
  redirect '/memos'
end

get '/memos/:id' do
  conn = PG::Connection.new(dbname: DB_NAME)
  @memo = conn.exec_params("SELECT * FROM #{TABLE_NAME} WHERE id = $1;", [params['id']]).to_a[0]
  conn.close
  erb :show
end

get '/memos/:id/edit' do
  conn = PG::Connection.new(dbname: DB_NAME)
  @memo = conn.exec_params("SELECT * FROM #{TABLE_NAME} WHERE id = $1;", [params['id']]).to_a[0]
  conn.close
  erb :edit
end

patch '/memos/:id' do
  conn = PG::Connection.new(dbname: DB_NAME)
  conn.exec_params("UPDATE #{TABLE_NAME} SET title = $1, body = $2 WHERE id = $3;", [params['title'], params['body'], params['id']])
  conn.close
  redirect '/memos'
end

delete '/memos/:id' do
  conn = PG::Connection.new(dbname: DB_NAME)
  conn.exec_params("DELETE FROM #{TABLE_NAME} WHERE id = $1;", [params['id']])
  conn.close
  redirect '/memos'
end
