require 'sinatra'
require 'sinatra/activerecord'
require 'securerandom'
require 'bcrypt'

class User < Activerecord::Base
	has_many :todos
	has_many :devices
	has_many :comments
 end

class Todo < Activerecord::Base
	belongs_to :user
end

class Comment < Activerecord::Base
	belongs_to :user
end

class Device < Activerecord::Base
	belongs_to :user
end

post '/user' do 
  u = User.new(username: params[:username], 
                  email: params[:email],
               password: Password.create(params[:password]))
  u.save
  u.to_json
end

delete '/user' do 
  u = User.find(params[:id])
  u.delete
  true.to_json
end

get '/todo' do
	user = Device.find_by_token(params["token"]).user
	user.todos.where("todo_date" => params["todo_date"]).to_json
end

post '/todo' do
	#todo에 글을 쓰는 것 (create)
	user = Device.find_by_token(params["token"]).user
	index = 0
	params["todos"].each do |t|
		Todo.create('user'=>user, 'content'=>t["content"], 'todo_date'=>Time.now, 'todo_index'=>index,
								'complete_check'=>false, 'revision_check'=>true)
		index = index + 1
		break if index > 5
	end
	user.todos.where("todo_date" => Time.now).to_json
end

put '/todo' do
	#todo 수정 하기 (update)
	user = Device.find_by_token(params["token"]).user
	todo = Todo.find(params["id"])
	if todo.user != user
		"error_001".to_json #view.js에서는 "error_001"이 떴을때 alert sign을 내보내게 하면 된다
	elsif todo.todo_date < Time.now
		"error_002".to_json
	else
		todo.content = params["content"]
		todo.complete_check = params["complete_check"]
		todo.save
		todo.to_json
	end
end

get '/comment' do
	#코멘트 읽기(read)
	user = Device.find_by_token(params["token"]).user
	user.comments.where(comment_date => params["comment_date"]).to_json
end

post '/comment' do
	#코멘트 작성하기(create)
	user = Device.find_by_token(params["token"]).user
	Comment.create("user" => user, "content" => params["content"], "comment_date" => Time.now).to_json
end

put '/comment' do
	#코멘트 수정하기(update)
	user = Device.find_by_token(params["token"]).user
	comment = Comment.find(params["id"])
	if user != comment.user
		"error_001".to_json
	elsif comment.comment_date < Time.now
		"error_002".to_json
	else
		comment.content = params["content"]
		comment.save
		comment.to_json
	end
end

delete '/comment' do
	#코멘트 삭제하기(delete)
	comment = Comment.find(params["id"])
	comment.delete
	true.to_json #쨘(=true, 아무 의미없는)
end

post '/device' do
	#로그인=device 정보를 생성한다(create)
	user = User.where("id" => params["id"]).first
	if !user.nil?
		if user.password == params["password"]
			Device.create("user" => user, "token" => SecureRandom.uuid, "os" => params["os"],
										"device_ver" => params["device_ver"]).to_json
		else
			"error_003".to_json #wrong password
		end
	else
		"error_004".to_json #id doesn't exist
	end
end
