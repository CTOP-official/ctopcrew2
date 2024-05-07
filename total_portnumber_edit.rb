require 'mysql2'
require 'http'
require 'crack'

def api_robot(port_number, name, phone)
    req = HTTP.get('https://unipass.customs.go.kr:38010/ext/rest/persEcmQry/retrievePersEcm?crkyCn=w240t254w013x074c030o090l0&persEcm='+port_number.to_s+'&pltxNm='+name.to_s+'&cralTelno='+phone.to_s)
    myXML  = Crack::XML.parse(req.to_s)
    myJSON = myXML.to_json
    myJSON = JSON.parse(myJSON)
    result = myJSON['persEcmQryRtnVo']
    if result['tCnt'].to_s == '1'
        return "1"
    else
        if result['persEcmQryRtnErrInfoVo'].to_s.include?("존재하지") or result['persEcmQryRtnErrInfoVo'].to_s.include?("성명과 일치하지")
            return "3"
        else
            return "2"
        end
    end
end

localClient = Mysql2::Client.new(:host => "localhost", :username => "ctop", :password => "0815", :database => "ctop")
result = localClient.query('select * from CTOPORDER')
result.each do |i|
    if i['api_result'] == nil

    else
        if i['api_result'].to_s.include?('불일치')
            a = i['ordName'].to_s
            b = i['ordTel'].to_s
            c = i['getName'].to_s
            d = i['getTel'].to_s
            port_number = i['pnum'].to_s
            p [a,b,c,d,port_number]
            text = ''
            result = api_robot(port_number, a, b)
            if result == '1'
                text = '정상(주문자)'
            elsif result == '2'
                text = '정상(주문자휴대폰불일치)'
            else
                result2 = api_robot(port_number, c ,d)
                if result2 == '1'
                    text = '정상(수령자)'
                elsif result2 == '2'
                    text = '정상(수령자휴대폰불일치)'
                else
                    text = '개통부오류'
                end
            end

            q_value = 'update CTOPORDER set api_result = "'+text+'" where _id = '+i['_id'].to_s
            puts q_value
            localClient.query(q_value)
        end
    end
end

localClient.close