
# 출처: https://kuduz.tistory.com/1085 [kini'n creations]

library(data.table)

# 일반적인 read.csv()함수를 이용한 데이타 불러오기----------------
sc<-read.csv("results.csv")
head(sc)
class(sc)

# fread()함수 이용----------------------------------------------
sc_dt <- fread('results.csv')
sc_dt

class(sc_dt)

# 두 함수간의 불러오기 시간비교----------------------------------------------------------
system.time(sc <- read.csv('results.csv'))
system.time(sc_dt <- fread('results.csv'))

# data.table() 함수를 사용해서 불러온 데이터에 대한 조건추출-------------------------
sc_dt[team=='Korea Republic',]
sc_dt

sc_dt[team=='Korea Republic' & opponent=='Japan', ]

sc_dt[team=='Korea Republic' | opponent== "Japan"]

sc_dt[team=='Korea Republic', 3]

sc_dt[team=='Korea Republic', opponent] # 결과가 벡터 형태로 출력됨. 계산을 위해서 데이터 테일블 형태로 출력을 원하면,

sc_dt[team=='Korea Republic', .(opponent)] # .(변수명) 으로 입력

sc_dt

sc_dt[team=='Korea Republic', .(평균득점=mean(team_score), 평균실점=mean(opponent_score))]

# DT[행, 열, by][  ]------------------------------------------------------------------------------- 
sc_dt[team=='Korea Republic', .(평균득점=mean(team_score), 평균실점=mean(opponent_score)), 
      by=.(opponent)]

#체이닝(chaining)을 활용하시면 편합니다. 체이닝은 이름 그대로 [ ] 사슬로 코드를 연결하는 걸 뜻합니다-------

sc_dt[team=='Korea Republic', .(평균득점=mean(team_score), 평균실점=mean(opponent_score)), 
      by=.(opponent)][order(평균득점, decreasing = TRUE),]

# 열을 추가할 때는 ':='----------------------------------------------------------------------

sc_dt

attach(sc_dt)

# 승/무/패를 알아보려고 할때 if() else()-------------------------------------------

sc_dt[, .(result=ifelse(team_score>opponent_score, '승', ifelse(team_score==opponent_score, '무', '패')))]


# 데이터에 붙이려면 '='가 아니라 ':='를 쓰면 됩니다. 대신 .()는 지워주셔야 합니다.--------------------

sc_dt[, result:=ifelse(team_score>opponent_score, '승', ifelse(team_score==opponent_score, '무', '패'))]
sc_dt

# 승이 많은 나라 뽑아보기---------------------------------------------------------

sc_dt[, .(승=sum(result=='승')), by=.(team)]

# order() 함수에서는 변수 이름 앞에 마이너스(-)를 붙이면 그 변수를 기준으로 내림차순 정렬을 함--------
sc_dt[, .(승=sum(result=='승')), by=.(team)][order(-승)][1:10]

sc_dt[, .(승=sum(result=='승')), by=.(team=='Korea Republic')] # 논리 연산자로 출력함

# 열 삭제 방법 ':=NULL'--------------------------------------------------

sc_dt[, result:=NULL]
sc_dt

# 승/무/패를 모두 보이게 할때는--------------------------------------------

sc_dt[, .(team, result=ifelse(team_score>opponent_score, '승', 
ifelse(team_score==opponent_score, '무', "패")))][, .(승=sum(result=='승'), 무=sum(result=='무'), 
패=sum(result=='패')), by=.(team)][order(-승)][1:10]

sc_dt

# 한일전 결과만 출력하면---------------------------------------------

sc_dt[team=='Korea Republic' & opponent =='Japan', .(team, result=ifelse(team_score>opponent_score,'승', 
ifelse(team_score==opponent_score, '무', "패")))][, .(승=sum(result=='승'), 무=sum(result=='무'), 패=sum(result=='패')),
      by=team]

# 한중(China)전 결과를 출력 해보면---------------
sc_dt[team=='Korea Republic' & opponent =='China', .(team, result=ifelse(team_score>opponent_score,'승', 
    ifelse(team_score==opponent_score, '무', "패")))][, .(승=sum(result=='승'), 무=sum(result=='무'), 패=sum(result=='패')),
    by=team]

# 중국에게 진 3패만을 출력해보면-------------------------------------------
sc_dt[team=='Korea Republic' & opponent =='China', .(team,date, tournament, team_score, opponent_score, result=ifelse(team_score>opponent_score,'승', 
     ifelse(team_score==opponent_score, '무', '패')))][result=='패']


##### 제일 중요한 열은 사실 'team' setkey()----------------------------------------------
# 크고 무거운 데이터를 처리하실 일이 있을 때는 setkey() 함수를 사용하시는 걸 잊지 마세요-------------

setkey(sc_dt, team)
sc_dt

# 한국 결과만 보고 싶을 때 sc_dt[team=='Korea Republic']이라고 썼지만 
# 이제는 sc_dt['Korea Republic']이라고 써도 같은 결과를 얻을 수 있습니다.

sc_dt['Korea Republic']

setkey(sc_dt, team, opponent) # setkey()안에 여러개를 지정해도 됨.
sc_dt['Korea Republic']

# Rolling join----------------------------------------------------------------------------------------
# 여러 데이터를 하나로 합치고 싶을 때가 있습니다. 
# data.table에서는 그냥 [ ] 안에 데이터를 넣는 것만으로 데이터를 합칠 수 있도록 하고 있습니다.

# 예제-------------------------------------

cart <- data.table(장바구니날짜=c('2018-04-01', '2018-06-02', '2018-06-30', '2018-07-15', '2018-08-01'),
                         사람=c('a', 'b', 'c', 'd', 'e'))
pay <- data.table(결제날짜=c('2018-05-01', '2018-06-01', '2018-07-01', '2018-08-01', '2018-09-01'),
                     사람=c('a', 'b', 'b', 'c', 'd'))
cart 
pay

# 사람을 기준으로 합치라고 R에게 알려주는 것. 그럴 때도 setkey() 함수를 쓰면 됩니다.----------------

setkey(cart, 사람)
setkey(pay, 사람)

cart[pay]

# 순서를 바꾸고 싶을때---------------------

cart[pay][, c(2,1,3)]

# 'e'라는 사람이 사라짐: 왜냐하면 'pay'날짜를 기준으로 했기 때문에----------------------------

pay[cart][, c(2,1,3)]

na.omit(pay[cart][, c(2,1,3)]) # na.omit()는 NA가 들어 있는 모든 행을 지웁니다. 

# 특정 열에서 NA가 있을 때만 지우고 싶을 때는 'cols=열 이름'을 쓰시면 됩니다

na.omit(pay[cart][, c(2,1,3)], cols='결제날짜') # 위에와 똑같이 작동함 



########### FIFA 랭킹을 붙여보자###################################################################

library(data.table)

rk <- fread('fifa_ranking.csv')
rk

sc_dt <- fread('results.csv')
sc_dt

# A매치 데이터는 1872년 11월 30일 경기 결과부터 들어 있는데 FIFA 랭킹은 1993년 8월 8일이 처음입니다. 
# 필요 없는 데이터를 빼고 시작하는 게 낫겠죠? 
# A매치 데이터에서 날짜(date) 열이 1993년 8월 8일 이후인 경기 결과만 남겨놓겠습니다.

sc_dt[date>='1993-08-08'] # indicating ' ' as character

sc_dt[, code:=date]

rk[, code:=rank_date]
rk

# 키열 지정----------------------------------------------------

setkey(sc_dt, team, code)
setkey(rk, country_full, code)

# 두 데이터를 합치는 건 'rk[sc_dt,="" roll="T]'라고 입력하면 될 겁니다---------------------

na.omit(rk[sc_dt, roll=T][, .(date, country_full, rank, opponent, team_score, opponent_score)])

rk_sc <- na.omit(rk[sc_dt, roll=T][, .(date, country_full, rank, opponent, team_score, opponent_score,tournament, code)]) 
rk_sc                                    










