require 'mysql2'
require 'roo'

client = Mysql2::Client.new(:host => "my8001.gabiadb.com", :username => "ctopctop", :password => "ctopdb0815!", :database => "ctop")
localClient = Mysql2::Client.new(:host => "localhost", :username => "ctop", :password => "0815", :database => "ctop")

# result = client.query('select * from DBCTOP')
# # file_name = './CTOP_DB.xlsx'
# # xlsx = Roo::Spreadsheet.open(file_name)
# # sheet = xlsx.sheet(0)
# # colums = sheet.row(1)
# # p colums
# result.each do |i|
# #     # i = Hash.new
# #     # data33 = sheet.row(nn)
# #     # colums.each_with_index do |kk,index3|
# #     #     i[kk] = data33[index3]
# #     # end
# #     puts(i['ID'].to_s + '   ==>  '+i['업체별상품코드'].to_s)
#     m = Hash.new
#     m['supType'] = i['공급방식']
#     m['comName'] = i['공급사']
#     m['name1'] = i['출고국가']
#     m['name2'] = i['출고국가영문']
#     m['selName'] = i['판매업체']
#     m['proType'] = i['품목']
#     m['enbrandName'] = i['브랜드영문명']
#     m['enName'] = i['영문상품명']
#     m['brandName'] = i['브랜드']
#     m['procode'] = i['업체별상품코드']
#     m['proDbName'] = i['DB용상품명']
#     m['proName'] = i['상품명']
#     m['counter'] = ''
#     m['godocode'] = i['고도몰상품코드']
#     m['tel'] = i['고객센터연락처']

#     v = m.values.map do |i|
#         '"'+i.to_s+'"'
#     end
#     result2 = localClient.query('select * from PRODUCT where procode = "'+m['procode'].to_s+'"')
#     if result2.size == 0
#         q = 'insert into PRODUCT('+m.keys.join(',')+') values('+v.join(',')+')'
#         puts q
#         localClient.query(q)
#     end

#     m2 = Hash.new
#     m2['proId'] = i['업체별상품코드']
#     m2['barcode'] = i['바코드']
#     m2['conCheck'] = ''
#     m2['optName1'] = i['옵션1']
#     m2['optName2'] = i['옵션2']
#     m2['optCon'] = i['수량']
#     m2['optCode'] = i['옵션코드']
#     m2['price'] = i['도매가']
#     m2['priceDel'] = i['배송비']
#     m2['url'] = i['상품URL']
#     m2['curCon'] = '100'

#     v2 = m2.values.map do |i|
#         '"'+i.to_s+'"'
#     end

#     q = 'insert into CTOPOPTION2('+m2.keys.join(',')+') values('+v2.join(',')+')'
#     puts q
#     localClient.query(q)
# end

 #result = client.query('select * from DBORDER where FD4 > "2023-01-01"')
 #result.each do |i|
#     m = Hash.new
#     m['date1'] = i['FD4']
#     m['date2'] = i['FD5']
#     m['date3'] = i['FD6']
#     m['name1'] = i['FD7']
#     m['market1'] = i['FD8']
#     m['date4'] = i['FD9']
#     m['deliNo'] = i['FD10']
#     m['code1'] = i['FD11']
#     m['unicode'] = i['FD12']
#     m['code2'] = i['FD13']
#     m['procode'] = i['FD16']
#     m['barcode'] = i['FD15']
#     m['con1'] = ''
#     m['optcon'] = i['FD21']
#     m['ordName'] = i['FD22']
#     m['ordTel'] = i['FD23']
#     m['getName'] = i['FD24']
#     m['getTel'] = i['FD25']
#     m['pnum'] = i['FD26']
#     m['enum'] = i['FD27']
#     m['home'] = i['FD28']
#     m['messege'] = i['FD29']
#     m['che1'] = i['FD43']
#     m['moneyNum'] = i['FD50']
#     m['money1'] = i['FD51']
#     m['money2'] = i['FD52']
#     m['money3'] = i['FD53']
#     m['money4'] = i['FD54']
#     m['moneyDate'] = i['FD55']
#     m['money5'] = i['FD56']
#     m['money6'] = i['FD57']

#     m2 = m.values.map do |i2|
#         '"'+i2.to_s.split('"').join('')+'"'
#     end

#     q = 'insert into CTOPORDER('+m.keys.join(',')+') values('+m2.join(',')+')'
#     puts q
#     localClient.query(q)

#     t = Time.now.to_s.split(' ')[0]
#     if i['FD30'].to_s != ''
#         q2 = 'insert into CTOPCS2(code2, content, name, time) values("'+i['FD13'].to_s+'","'+i['FD30'].to_s.split('"').join('')+'","'+i['FD31'].to_s+'","'+t+'")'
#         puts q2
#         localClient.query(q2)
#     end
#     if i['FD32'].to_s != ''
#         q2 = 'insert into CTOPCS2(code2, content, name, time) values("'+i['FD13'].to_s+'","'+i['FD32'].to_s.split('"').join('')+'","'+i['FD33'].to_s+'","'+t+'")'
#         puts q2
#         localClient.query(q2)
#     end
#     if i['FD34'].to_s != ''
#         q2 = 'insert into CTOPCS2(code2, content, name, time) values("'+i['FD13'].to_s+'","'+i['FD34'].to_s.split('"').join('')+'","'+i['FD35'].to_s+'","'+t+'")'
#         puts q2
#         localClient.query(q2)
#     end

#     if i['FD44'].to_s != ''
#         q2 = 'insert into CTOPDR(code2, time, drTime, name) values("'+i['FD13'].to_s+'","'+i['FD44']+'","'+i['FD45']+'","'+i['FD46']+'")'
#         puts q2
#         localClient.query(q2)
#     end
# end


#CSV.open('./productTotalData.csv', 'w') do |cs|
#  result = localClient.query('select * from PRODUCT')
#  result.each do |product|
#    productData = product.values
#    code = product["procode"].to_s

#    result2 = localClient.query("select * from CTOPOPTION2 where proId = '"+code+"'")
#    result2.each do |option|
#      optionData = option.values
#      rowData = productData + optionData
#      p rowData
#      cs << rowData
#    end
#  end
#end

result = localClient.query("select * from CTOPOPTION2 where curCon = '0'")
result.each do |i|
    barcode = i['barcode']
    rr = client.query('select * from DBSOLDOUT where 바코드 = "'+barcode+'"')
    if rr.size == 0
      q = 'update CTOPOPTION2 set curCon = "100" where _id = ' + i['_id'].to_s
      puts q
      localClient.query(q)
    end
end

result = client.query('select * from DBSOLDOUT')
result.each do |i|
    barcode = i['바코드']
    if barcode.to_s == ''

    else
        q = 'update CTOPOPTION2 set curCon = "0" where barcode = "'+barcode.to_s+'"'
        puts q
        localClient.query(q)
    end
end


# client.close
# result = localClient.query('select * from CTOPOPTION2 where proId like "%+%"')
# result.each do |i|
#     v = i.values.map do |k|
#         if k.to_s.include?('+')
#             '"'+k.to_s.split('+')[0].split(' ').join(' ')+'"'
#         else
#             '"'+k.to_s+'"'
#         end
#     end
#     v2 = i.values.map do |k|
#         if k.to_s.include?('+')
#             '"'+k.to_s.split('+')[1].split(' ').join(' ')+'"'
#         else
#             '"'+k.to_s+'"'
#        end
#     end
#
#     puts q = 'insert into CTOPOPTION2('+i.keys[1..-1].join(',')+') values('+v[1..-1].join(',')+')'
#     q2 = 'insert into CTOPOPTION2('+i.keys[1..-1].join(',')+') values('+v2[1..-1].join(',')+')'
#     q2 = q2.split("건기식").join('사은품')
#     puts q2
#     localClient.query(q)
#     localClient.query(q2)
# end

client.close
localClient.close
