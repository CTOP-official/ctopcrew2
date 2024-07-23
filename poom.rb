require 'roo'
require 'mysql2'

class Soonje
    def dbconnect
        @localClient = Mysql2::Client.new(:host => "localhost", :username => "ctop", :password => "0815", :database => "ctop")
    end

    def excel_get(file_name)
        xlsx = Roo::Spreadsheet.open(file_name)
        return xlsx.sheet(0)
    end

    def main
        dbconnect()
        excel = excel_get('data37.xlsx')
        excel.column(1).each_with_index do |d, index|
            index2 = index + 1
            if index2 > 1
                dd = excel.row(index2)
                procode = dd[2].to_s
                barcode = dd[8].to_s
                poom = dd[23].to_s
                puts " 상품코드 : #{procode} , 바코드 : #{barcode}, 품절여부 : #{poom}"
                puts q = 'update CTOPOPTION2 set curCon = "0" where barcode = "'+barcode+'"'
                @localClient.query(q)
            end 
        end
    end
end

soonje = Soonje.new
soonje.main
