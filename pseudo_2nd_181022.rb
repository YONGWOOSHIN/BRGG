서버 연동을 위한 'require' 명령어 작성
DB 연동을 위한 'require' 명령어 작성
*google 로그인 연동을 위한 config 파일 작성

user class 정의(has many todo, device)
todo class 정의(belongs to)
comment class 정의(belongs to)
device class 정의(belongs to)

post '/signup_process' do
  username, email, unique_key를 구글 api를 통해 파라미터(params)로 받는다
  device 정보(os,device_name etc)를 파라미터로 받는다.
  정상적이지 않은 값이 들어왔는지 확인한다.
  정상적이지 않다면 가입 불가 메시지를 띄운다(*view)
  정상적이라면, 회원가입을 시작한다.
  제일 먼저 빈 유저를 만들고(empty)
  뷰에서 넘어온 username을 empty 유저에 넣는다.
  뷰에서 넘어온 email을 empty 유저에 넣는다.
  뷰에서 넘어온 unique_key을 empty 유저에 넣는다.
  값을 넣은 유저를 저장한다.
  빈 디바이스를 만들고(empty)
  뷰에서 넘어온 device 정보를 empty 디바이스에 넣는다.
  값을 넣은 디바이스를 저장한다.
  새로 생긴 유저를 로그인시켜주고, 초기 페이지('/')로 이동시킨다.
end

post '/signin' do
  만약 디바이스 정보가 없다면, 다중접속
  username이 있고 password가 맞다면,
    만약, 최초 로그인이라면 first_view(설명 ani)로 보내준다
    그렇지 않다면 main_view로 보내준다
end

post '/signout' do

end

get '/' do
  만약 유저 정보가 없다면, 회원가입(signup_process)으로 이동
  * view에서 '구글 계정으로 로그인'을 띄워준다
  그렇지 않다면, 로그인(signin)으로 이동
  설명 ani(view 파일)실행
  시작 누르면, main_view로 이동시킨다
end

post '/view_main/:date' do
  만약 유저 로그인이 끊겼다면, 로그인 페이지로 이동
  만약 입력받은 날짜가 비어있다면(nil), 오늘 날짜를 입력한다.
  입력받은 날짜를 확인하고, 날짜에 해당하는 todo를 모두 불러온다
  * view에서 todo를 순서대로 띄워준다
end

get '/create_and_freeze' do
  #먼저, 오늘 작성할 새로운 todo를 db에 생성한다
  만약 0시가 지나면(whenever gem 활용), 아래의 동작을 수행한다
  6개의 빈 todo를 만든다(콘텐츠, 날짜, 순서, 수행여부, 수정여부)
  *날짜는 오늘의 날짜를 6개 동시에 입력한다
  *순서는 0부터 5를 반드시 입력한다
  *수행여부는 false로, 수정여부는 true로 선언한다
  #다음으로, 오늘 작성할 새로운 comment를 db에 생성한다
  1개의 빈 comment를 만든다(콘텐츠, 날짜, 수정여부)
  *수정여부는 true로 선언한다
  #마지막으로, 어제 작성한 모든 todo를 수정하지 못하게 freeze한다
  todo의 날짜가 오늘 날짜보다 앞이라면 수정여부를 false로 바꾼다. (todo, comment 모두)
end

post '/todo_update' do
  만약 유저 로그인이 끊겼다면, 로그인 페이지로 이동
  * view에서 수정여부가 false라면, 여기로 오지 않는다
  날짜와 순서를 체크한다
  뷰에서 넘어온 todo를 그 날짜와 순서의 todo에 넣는다

  =====================todo 작성 policies=====================
  넘어온 todo가 20자를 초과한다면, warning sign을 내보낸다
  넘어온 todo가 특수문자를 포함한다면, warning sign을 내보낸다
  넘어온 todo가 욕설을 포함한다면, warning sign을 내보낸다
  ============================================================

  warning sign이 없는 todo라면, 채워진 todo를 저장한다.
  *view에서는 채워진 todo를 띄워준다
end

get '/todo_check' do
  만약 유저 로그인이 끊겼다면, 로그인 페이지로 이동
  뷰에서 수행여부 넘어온다면, 수행여부를 1(true)로 만든다.
  *view에서 state가 0이라면 체크박스를 빈 칸으로하고 editable 객체를 띄워준다
  *state가 1이라면 체크박스를 채우고 uneditable 객체로 띄워준다
end

get '/todo_order' do
  만약 유저 로그인이 끊겼다면, 로그인 페이지로 이동
  view에서의 index를 불러와서 todo db에 상시 업데이트
end

post '/comment_update' do
  만약 유저 로그인이 끊겼다면, 로그인 페이지로 이동
  뷰에서 넘어온 코멘트를 empty 코멘트에 넣는다
  =====================코멘트 작성 policies=====================
  넘어온 코멘트가 100자를 초과한다면, warning sign을 내보낸다
  넘어온 코멘트가 욕설을 포함한다면, warning sign을 내보낸다
  ============================================================
  warning sign이 없는 코멘트라면, 채워진 코멘트를 저장한다.
  *view에서는 채워진 코멘트를 띄워준다
end
