require 'mysql2'
require 'simple_xlsx_reader'
require 'http'
require "crack"
require 'json'

# req = HTTP.get('https://unipass.customs.go.kr:38010/ext/rest/persEcmQry/retrievePersEcm?crkyCn=w240t254w013x074c030o090l0&persEcm=P180006932077&pltxNm=이장호&cralTelno=01035284610')
# myXML  = Crack::XML.parse(req.to_s)
# myJSON = myXML.to_json
# myJSON = JSON.parse(myJSON)
# puts myJSON['persEcmQryRtnVo']['tCnt']


# client = Mysql2::Client.new(:host => "localhost", :username => "ctop", :password => "0815", :database => "ctop")
# m = Array.new
# for n in 2..23
#     m << 'data_'+n.to_s+' varchar(256)'
# end
# q = 'create table ctop_barcode(_id int primary key auto_increment,'+m.join(',')+')'
# puts q
# client.query(q)
# rows2 = SimpleXlsxReader.open('./CTOP_DB.xlsx').sheets.first.rows
# rows2.each_with_index do |i,index|
#     data_x = Array.new
#     data_v = Array.new
#     for n in 2..23
#         data_x << 'data_'+n.to_s
#         data_v << '"'+i[n-1].to_s+'"'
#     end

#     qq = 'insert into ctop_barcode('+data_x.join(',')+') values('+data_v.join(',')+')'

#     if index > 0
#         puts qq
#         client.query(qq)
#     end

#     if index < 10
#         gets.chomp
#     end
# end



client = Mysql2::Client.new(:host => "my8001.gabiadb.com", :username => "ctopctop", :password => "ctopdb0815!", :database => "ctop")
result = client.query('select * from DBCTOP limit 10')
result.each do |i|
    p i
end
client.close()