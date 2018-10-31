require 'sinatra'
require 'sinatra/activerecord'


class User < Activerecord::Base
	has_many: todos
  	has_many: devices
  	has_many: comments
 end

class Todo < Activerecord::Base
	belongs_to: User
 }

class Comment < Activerecord::Base
	belongs_to: User
 }

class Device < Activerecord::Base
	belongs_to: User
 }

#signup, login, logout, signout 구현

post '/signup' do
	#회원가입이 완료된 직후에 웰컴 메시지를 띄워준다
	redirect '/welcome'
end

post '/signout' do
	redirect '/'
end

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
  * view에서 todo를 순서대로 띄워준다
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