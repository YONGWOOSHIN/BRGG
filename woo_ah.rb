require 'sinatra'
require 'sinatra/activerecord'

enable :sessions

class Post < ActiveRecord::Base
  has_many    :replies
  belongs_to  :user
end

class Reply < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
end

class User < ActiveRecord::Base
  has_many  :posts
  has_many  :replies
end

get '/' do 
  if session["user_id"].nil?
    redirect '/login'
  else
    @user = User.find(session["user_id"])
    @posts = Post.all
    erb :vvv
  end
end

get '/login' do
  erb :login
end

get '/signup' do 
  erb :signup
end

post '/login_process' do 
  user = User.where("username" => params["username"]).first
  if !user.nil? and user.password == params["password"]
    session["user_id"] = user.id
  end
  redirect "/"
end

post '/signup_process' do 
  if params["password"] != params["password_confirm"]
    redirect back
  else
    user = User.new
    user.username = params["username"]
    user.password = params["password"]
    user.save

    session["user_id"] = user.id
    redirect '/'
  end
end

post '/create_reply' do 
  user = User.find(session["user_id"])
  p = Reply.new
  p.user = user
  p.post_id = params["post_id"]
  p.content = params["content"]
  p.save
  redirect '/'
end

post '/create' do
  user = User.find(session["user_id"])
  p = Post.new
  p.user = user
  p.title = params["title"]
  p.content = params["content"]
  p.save
  redirect '/'
end

get '/delete/:your_vvv_post_id' do 
  p = Post.find(params["your_vvv_post_id"])
  p.delete
  redirect '/'
end

get '/logout' do 
  session.clear
  redirect '/'
end
