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
conn = connect_db(DB_NAME)
conn.exec("CREATE TABLE IF NOT EXISTS memo(
            id CHAR(36) NOT NULL,
            title VARCHAR(100) NOT NULL,
            body VARCHAR(1000),
            created_at TIMESTAMP,
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
  conn = connect_db(DB_NAME)
  @memos = conn.exec("SELECT * FROM #{TABLE_NAME} ORDER BY created_at;")
  conn.close
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  id = SecureRandom.uuid
  conn = connect_db(DB_NAME)
  conn.exec_params("INSERT INTO #{TABLE_NAME} VALUES($1, $2, $3, current_timestamp);", [id, params['title'], params['body']])
  conn.close
  redirect '/memos'
end

get '/memos/:id' do
  conn = connect_db(DB_NAME)
  @memo = conn.exec_params("SELECT * FROM #{TABLE_NAME} WHERE id = $1;", [params['id']]).first
  conn.close
  erb :show
end

get '/memos/:id/edit' do
  conn = connect_db(DB_NAME)
  @memo = conn.exec_params("SELECT * FROM #{TABLE_NAME} WHERE id = $1;", [params['id']]).first
  conn.close
  erb :edit
end

patch '/memos/:id' do
  conn = connect_db(DB_NAME)
  conn.exec_params("UPDATE #{TABLE_NAME} SET title = $1, body = $2 WHERE id = $3;", [params['title'], params['body'], params['id']])
  conn.close
  redirect '/memos'
end

delete '/memos/:id' do
  conn = connect_db(DB_NAME)
  conn.exec_params("DELETE FROM #{TABLE_NAME} WHERE id = $1;", [params['id']])
  conn.close
  redirect '/memos'
end

private

def connect_db(db_name)
  PG::Connection.new(dbname: db_name)
end
