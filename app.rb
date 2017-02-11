#encoding: utf-8
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'leprosorium.db'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db
  @db.execute 'CREATE TABLE IF NOT EXISTS "Posts"
                (
                   "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                    "create_date" DATE,
                    "content" TEXT
                );'
end

get '/' do
  @table_posts = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'

	erb :index
end

get '/new' do
	erb :new
end

post '/new.erb' do
  @content = params[:text_area]
    if @content.length <= 0
      @error = "Type post text "
      return erb :new
    end

  #Сохранение данный в базе данныйх
  @db.execute 'INSERT INTO Posts (create_date, content) VALUES (datetime(),?)', [@content]

  redirect to '/'
  # erb "You typet #{@content}"
end

get '/posts' do

  erb :post
end