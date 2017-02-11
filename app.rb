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

  @db.execute 'CREATE TABLE IF NOT EXISTS "Comments"
                (
                   "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                    "create_date" DATE,
                    "content" TEXT,
                    "post_id" INTEGER,
                    "name_commentator" TEXT
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

#вывод информации о посте
get '/details/:post_id' do
  @post_id = params[:post_id]
  @table_posts = @db.execute 'SELECT * FROM Posts WHERE id = ?', @post_id
  #Запрос таблицы комментариев к базе данных
  @comment_table = @db.execute 'SELECT * FROM Comments WHERE post_id = ?', @post_id

  erb :details
end

post '/details/:post_id' do
  @post_id = params[:post_id]
  @name_commentator = params[:name_commentator]
  @table_posts = @db.execute 'SELECT * FROM Posts WHERE id = ?', @post_id
  @comment = params[:comment]
  @error = []
  validation = {:name_commentator => 'You not enter name',:comment => 'You not enter comment'}
  validation.each do |key,value|
    if params[key] == ''
      @error << value
    end
  end

  if @error.size != 0
    @error.join(', ')
    return  erb :details
  end

  #Сохранение данный в базе данныйх
  @db.execute 'INSERT INTO Comments
                (
                  create_date,
                  content,
                  post_id,
                  name_commentator
                )
                VALUES
                (
                  datetime(),
                  ?,
                  ?,
                  ?
                )',
              [@comment,@post_id,@name_commentator]

  #Запрос таблицы комментариев к базе данных
  @comment_table = @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', @post_id
  erb :details
end