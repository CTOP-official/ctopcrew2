require 'mysql2'

client = Mysql2::Client.new(:host => "localhost", :username => "ctop", :password => "0815", :database => "ctop")

# m = Hash.new
# m['작성일'] = 'date1'
# m['주문일'] = 'date2'
# m['발주일'] = 'date3'
# m['업체명'] = 'name1'
# m['마켓명'] = 'market1'
# m['출고일'] = 'date4'
# m['송장번호'] = 'deliNo'
# m['도매주문번호'] = 'code1'
# m['고유번호'] = 'unicode'
# m['소매주문번호'] = 'code2'
# m['상품코드'] = 'procode'
# m['바코드'] = 'barcode'
# m['마켓주문수량'] = 'con1'
# m['옵션수량'] = 'optcon'
# m['주문자명'] = 'ordName'
# m['주문자휴대폰'] = 'ordTel'
# m['수령자'] = 'getName'
# m['수령자휴대폰'] = 'getTel'
# m['개통부'] = 'pnum'
# m['우편번호'] = 'enum'
# m['주소'] = 'home'
# m['배송메세지'] = 'messege'
# m['회수여부'] = 'che1'
# m['입금계좌'] = 'moneyNum'
# m['판매가'] = 'money1'
# m['배송비'] = 'money2'
# m['수수료'] = 'money3'
# m['정산금액'] = 'money4'
# m['정산확정일'] = 'moneyDate'
# m['원가'] = 'money5'
# m['배송비2'] = 'money6'

# m2 = m.values
# m2 = m2.map do |i|
#     ''+i+' varchar(256)'
# end

# q = 'create table CTOPORDER(_id int primary key auto_increment,'+m2.join(',')+')'
# q = 'create table CTOPCS2(_id int primary key auto_increment,code2 varchar(256) not null, content varchar(2048), name varchar(256), time varchar(256))'
# q = 'create table CTOPDR(_id int primary key auto_increment,code2 varchar(256) not null, time varchar(256), drTime varchar(256), name varchar(256))'
# q = 'create table PRODUCT(_id int primary key auto_increment,supType varchar(256), comName varchar(256), name1 varchar(256), name2 varchar(256), selName varchar(256), proType varchar(256), enbrandName varchar(256), enName varchar(256), brandName varchar(256), procode varchar(256), proDbName varchar(256), proName varchar(256), counter varchar(256), godocode varchar(256), tel varchar(256))'
# q = 'create table CTOPOPTION2(_id int primary key auto_increment,proId varchar(256) not null, barcode varchar(256) not null, conCheck varchar(256), optName1 varchar(256), optName2 varchar(256), optCon varchar(256), optCode varchar(256), price varchar(256), priceDel varchar(256), url varchar(256), curCon varchar(256))'
# q = 'alter table CTOPORDER add column productName varchar(256)'
puts q
client.query(q)
client.close