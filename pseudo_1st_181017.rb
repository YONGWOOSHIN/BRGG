서버 연동을 위한 'require' 명령어 작성
DB 연동을 위한 'require' 명령어 작성
*google 로그인 연동을 위한 config 파일 작성

user class 정의(has many)
todo class 정의(belongs to)
comment class 정의(belongs to)

post '/signup_process' do
  "password"와 "password_confirm"을 파라미터(params)로 받는다
  그리고 pw와 pw_confirm의 내용이 같은지 확인하고,
  그 둘의 내용이 다르다면 다시 입력으로 되돌린다.
  그 둘의 내용이 같다면, 이제 회원가입을 시작한다.
  제일 먼저 빈 유저를 만들고(empty)
  뷰에서 넘어온 username을 empty 유저에 넣는다.
  그리고 뷰에서 넘어온 password를 empty 유저에 넣는다.
  이때 pw와 pw_confirm은 내용이 같으니, 아무거나 넣어도 상관없다
  이렇게 값을 넣은 다음 빈 유저를 저장한다.

  새로 생긴 유저를 로그인시켜주고
  (로그인 안하고 다시 입력하게 해줘도 됨)
  메인 페이지로 이동시킨다.
end

post '/signin' do
  디바이스 정보(os ver.,)가 없다면, 다중접속
  username이 있고 password가 맞다면,
    만약, 최초 로그인이라면 first_view(설명 ani)로 보내준다
    그렇지 않다면 main_view로 보내준다
end

get '/view_first' do
  설명 ani(view 파일)실행
  시작 누르면, main_view로 보내준다
end

get '/view_main' do
  만약 유저 로그인이 끊겼다면, 로그인 페이지로 이동
  params[todo.date] = 오늘 날짜  
  #view하려는 날짜를 받아와서 그 날의 todo를 띄워주려면 어떻게? 
  #빈 todo를 생성하는 건 main에서인지? create에서인지? 
  날짜에 해당하는 todo를 모두 불러온다
  * view에서 todo를 순서대로 띄워준다
end

post '/view_main/:date' do
  만약 유저 로그인이 끊겼다면, 로그인 페이지로 이동
  입력받은 날짜를 확인한다
  날짜에 해당하는 todo를 모두 불러온다
  * view에서 todo를 순서대로 띄워준다
end

#todo_create를 하루 맨 처음 접속시에만 진행하려면 어떻게?
post '/todo_create' do
  6개의 빈 todo를 만든다(콘텐츠, 날짜, 순서, 수행여부, 수정여부)
  *날짜는 오늘의 날짜를 6개 동시에 입력한다
  *순서는 0부터 5를 반드시 입력한다
  *수행여부는 false로, 수정여부는 true로 선언한다
end

post '/comment_create' do
  1개의 빈 comment를 만든다(콘텐츠, 날짜, 수정여부)
  *수정여부는 true로 선언한다
end

#freeze를 create와 동시에 하는 것 vs. 따로 하는 것 중 무엇이 좋을까?
get '/freeze' do
  만약 유저 로그인이 끊겼다면, 로그인 페이지로 이동
  todo의 날짜가 오늘 날짜보다 앞이라면 수정여부를 false로 바꾼다. (todo, comment 모두)
end

post '/todo_write' do
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
  *view에서 state가 0이라면 체크박스를 빈 칸으로, state가 1이라면 체크박스를 채운다
end

get '/todo_order' do
  만약 유저 로그인이 끊겼다면, 로그인 페이지로 이동
  view에서의 index를 불러와서 todo db에 상시 업데이트
end

#comment db를 따로 파는 것이 효과적인가? or todo에 column을 새로 넣는 것
post '/comment_write' do
  만약 유저 로그인이 끊겼다면, 로그인 페이지로 이동
  뷰에서 넘어온 코멘트를 empty 코멘트에 넣는다
  =====================코멘트 작성 policies=====================
  넘어온 코멘트가 100자를 초과한다면, warning sign을 내보낸다
  넘어온 코멘트가 욕설을 포함한다면, warning sign을 내보낸다
  ============================================================
  warning sign이 없는 코멘트라면, 채워진 코멘트를 저장한다.
  *view에서는 채워진 코멘트를 띄워준다
end