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


# 키열 지정----------------------------------------------------

setkey(sc_dt, team, code)
setkey(rk, country_full, code)

# 두 데이터를 합치는 건 'rk[sc_dt,="" roll="T]'라고 입력하면 될 겁니다---------------------

na.omit(rk[sc_dt, roll=T][, .(date, country_full, rank, opponent, team_score, opponent_score)])

rk_sc <- na.omit(rk[sc_dt, roll=T][, .(date, country_full, rank, opponent, team_score, opponent_score,tournament, code)]) 
rk_sc                                    

# 상대팀 랭킹-----------------------------------------------

rk_sc <- na.omit(rk[sc_dt, roll=T][, .(date, country_full, rank, opponent, team_score, opponent_score,
                                    tournament, code)])                            

names(rk_sc)[2] <- 'team'
rk_sc

names(rk_sc)[3] <- 'team_rank'
rk_sc

c(names(rk_sc)[2], names(rk_sc)[3])

# setkey() 설정----------------------------------------------------------------

setkey(rk_sc, opponent, code)

rk_sc <- na.omit(rk[rk_sc, roll=T][, .(date, team, team_rank, country_full, rank, team_score,
                                       opponent_score, tournament)])
rk_sc                                       

names(rk_sc)[5] <- 'opponent_rank'
names(rk_sc)[4] <- 'opponent'

c(names(rk_sc)[5],names(rk_sc)[4])

head(rk_sc[, 1:5])

# 랭킹 1위 성적 확인---------------------------------------------

rk_sc[team_rank==1, .(결과=ifelse(team_score>opponent_score, '승',
  ifelse(team_score==opponent_score, '무', "패")))][, .(승=sum(결과=='승'), 무=sum(결과=='무'), 패=sum(결과=='패'))]

# 한국이 FIFA 랭킹 1위 팀을 상대로 어떤 성적을 기록했는지 보려면?-------------

rk_sc[team=='Korea Republic' & opponent_rank==1, .(date, tournament, opponent, 
      결과=ifelse(team_score>opponent_score, '승', ifelse(team_score==opponent_score, '무', "패")))][결과=='승']
  






