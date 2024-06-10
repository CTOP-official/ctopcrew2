require 'mysql2'

localClient = Mysql2::Client.new(:host => "localhost", :username => "ctop", :password => "0815", :database => "ctop")

result = localClient.query("select * from CTOPOPTION2 where curCon = '0'")
result.each do |i|
    barcode = i['barcode']
    if ['02','03','04','05','06'].include?(barcode.split('-')[-1])

    else
        for n in 2..6
            q = "update CTOPOPTION2 set curCon = '0' where barcode = '"+barcode+"-0"+n.to_s+"'"
            puts q
            localClient.query(q)
        end
    end
end
