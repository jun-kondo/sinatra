# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'erb'
require 'cgi'
require 'securerandom'
require 'pg'

PG::Connection.new(dbname: 'memo').exec("CREATE TABLE IF NOT EXISTS memo(
                                      id CHAR(36) NOT NULL,
                                      title VARCHAR(20) NOT NULL,
                                      body VARCHAR(100),
                                      PRIMARY KEY (id));")

helpers do
  def link_to(text, url)
    "<a href=#{url}>#{text}</a>"
  end
end

get '/' do
  redirect 'memos'
end

get '/memos' do
  conn = PG::Connection.new(dbname: 'memo')
  @memos = conn.exec('SELECT * FROM memo;').to_a
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  id = SecureRandom.uuid
  conn = PG::Connection.new(dbname: 'memo')
  conn.exec_params('INSERT INTO memo VALUES($1, $2, $3);', [id, params['title'], params['body']])
  redirect '/memos'
end

get '/memos/:id' do
  conn = PG::Connection.new(dbname: 'memo')
  @memo = conn.exec_params('SELECT * FROM memo WHERE id=$1;', [params['id']]).to_a[0]
  erb :show
end

get '/memos/:id/edit' do
  conn = PG::Connection.new(dbname: 'memo')
  @memo = conn.exec_params('SELECT * FROM memo WHERE id=$1;', [params['id']]).to_a[0]
  erb :edit
end

patch '/memos/:id' do
  conn = PG::Connection.new(dbname: 'memo')
  conn.exec_params('UPDATE memo SET title=$1, body=$2 WHERE id=$3;', [params['title'], params['body'], params['id']])
  redirect '/memos'
end

delete '/memos/:id' do
  conn = PG::Connection.new(dbname: 'memo')
  conn.exec_params('DELETE FROM memo WHERE id=$1;', [params['id']])
  redirect '/memos'
end
