require 'sinatra'
require 'sinatra/activerecord'
require 'securerandom'


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

#signup, login, logout, signout 구현

=begin
post '/signup' do
	#회원가입이 완료된 직후에 웰컴 메시지를 띄워준다
	redirect '/welcome'
end

post '/signout' do
	redirect '/'
end
=end

# app은 session이 없다(web은 같은 서버에서 돌기 때문에 @로 할 수 있다)
# app은 돌아가는 site와 server가 서로 다르다
# 1차적으로 암호화된 token을 던진다. app이 token을 들고 있고 서버에 던져주면 누구인지 identify한다
# token은 params로 던진다

get '/todo' do
	#todo를 읽어 오는 것, 데이터를 얻어 오는 것(read)
=begin
	token = params["token"]
	device = Device.find_by_token(token) #where 써도 무방
	#eqaul to above: device = Device.where("token"=>token).first -> where은 array로 return
	user = device.user #token을 바탕으로 user를 뽑아냈음
=end
	user = Device.find_by_token(params["token"]).user
	#in a line coded, should be copied
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

get '/user' do
	# 내 정보 보기(read)
end

post '/user' do
	# 회원 가입(create)
end

delete '/user' do
	#탈퇴(delete)
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

=begin
get '/' do
	if user.user_name.nil?
		redirect '/signup'
	else
		redirect '/view_main/:date'
  end
end

get '/welcome' do
	erb :welcome
end

post '/view_main/:date' do
	if todo.date.nil?
		params["date"] = Time.now.strftime("%Y%m%d") # lists.date가 string인지 integer인지
  	@todos = Todo.all
  	erb :main
  #view에서 todo를 순서대로 띄워준다(-> json)
end

get '/create_and_freeze' do
  #먼저, 오늘 작성할 새로운 todo를 db에 생성한다
  every 1.day, :at => '0:00 am' do
    for i in 0..5
    	t = Todo.new
    	t.content = nil
    	t.date = Time.now.strftime("%Y%m%d").to_i
    	t.index = i
    	t.complete_check = false
    	t.revision_check = true
    	t.save
    end
  	#다음으로, 오늘 작성할 새로운 comment를 db에 생성한다
  	c = Comment.new
  	c.content = nil
  	c.date = Time.now.strftime("%Y%m%d").to_i
  	c.revision_check = true
  	#마지막으로, 어제 작성한 모든 todo를 수정하지 못하게 freeze한다
  	#어제 작성한 todo를 찾는다
  	if t.date < Time.now.strftime("%Y%m%d").to_i
  		t.revision_check = false
  	end
  	#어제 작성한 comment를 찾는다
  	if c.date < Time.now.strftime("%Y%m%d").to_i
  		c.revision_check = false
  	end
  end
  redirect '/view_main:date'
end

post '/todo_update/:date/:index' do
	#view에서 수정여부가 false라면, 여기로 오지 않는다

	# 날짜와 순서를 체크한다
	t = Todo.find(date: params["date"], index: params["index"])
	# 뷰에서 넘어온 todo를 그 날짜와 순서의 todo에 넣는다
	t.content = params["content"]
	# warning sign이 없는 todo라면, 채워진 todo를 저장한다.
	t.save
	# view에서는 채워진 todo를 띄워준다
  =====================todo 작성 policies=====================
  넘어온 todo가 20자를 초과한다면, warning sign을 내보낸다
  넘어온 todo가 특수문자를 포함한다면, warning sign을 내보낸다
  넘어온 todo가 욕설을 포함한다면, warning sign을 내보낸다
  ============================================================
end

get '/todo_check/:date/:index' do
	# 날짜와 순서를 체크한다
	t = Todo.where(date: params["date"], index: params["index"])
	# 뷰에서 수행여부 넘어온다면, 수행여부를 1(true)로 만든다.
	t.complete_check = params["complete_check"]
	end
	t.save
	# view에서 state가 0이라면 체크박스를 빈 칸으로하고 editable 객체를 띄워준다
	# state가 1이라면 체크박스를 채우고 uneditable 객체로 띄워준다
end

post '/todo_order' do
	# view에서의 index를 불러와서 todo db에 상시 업데이트

	t.index = params["index"]
	t.save
end

post '/comment_update/:date' do
	# 뷰에서 넘어온 코멘트를 empty 코멘트에 넣는다
	c = Comment.find(params["date"])
	c.content = params["content"]
  =====================코멘트 작성 policies=====================
  넘어온 코멘트가 100자를 초과한다면, warning sign을 내보낸다
  넘어온 코멘트가 욕설을 포함한다면, warning sign을 내보낸다
  ============================================================
  	# warning sign이 없는 코멘트라면, 채워진 코멘트를 저장한다.
  	c.save
  	# view에서는 채워진 코멘트를 띄워준다
end
=end
