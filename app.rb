#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	(id	INTEGER PRIMARY KEY AUTOINCREMENT,
	created_date	TEXT,
	content	TEXT)'
end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index		
end

get '/new' do
  erb :new
end

post '/new' do
	# получаем переменную из post-запроса
  content = params[:content]

  if content.size <= 0
  	@error = "Type text please"
  	return erb :new
  end

@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]
	
	redirect to '/'
end

# выводим информацию о посте
get '/details/:post_id' do
# получаем переменную из url`a
  post_id = params[:post_id]
# получаем список постов (у нас будет только 1 пост показан)
  results = @db.execute 'select * from Posts where id = ?', [post_id]
# выбираем этот 1 пост в переменную @row
  @row = results[0]
# вовзращаем представление details erb
  erb :details
end

# обработчик post-запроса /details/..(4,2,222..)
# браузер отправляет данные на сервер, а мы их принимаем
post '/details/:post_id' do
# получаем переменную из url`a	
	post_id = params[:post_id]
# получаем переменную из post-запроса
  	content = params[:content]
  	erb "You typed comment #{content} for post #{post_id}"
end
