require 'fuzzystringmatch'
require 'rubyXL/convenience_methods'

class HomeController < ApplicationController
    def index

    end

    def barcode

    end

    def orderGet

    end

    def login
        if session[:id] == nil

        else
        redirect_to '/'
        end
    end

    def setTable1

    end

    def login_action
        user_id = params['id'].to_s
        user_pw = params['pw'].to_s
        result = ActiveRecord::Base.connection.execute("SELECT * FROM ctop_user where ct_id = '#{user_id}' and ct_pw = '#{user_pw}'")
        answer = Hash.new
        result.each do |i|
        answer = i
        end
        if result.size == 0
        render :json => {'result' => 'fail'}
        else
        session[:id] = answer[1].to_s
        session[:name] = answer[3].to_s
        session[:power] = answer[4].to_s
        render :json => {'result' => 'ok'}
        end
    end

    def logout
        reset_session
        redirect_to '/login', notice: '로그아웃되었습니다.'
    end

    

    def checkCode1
        answer = 'true'
        result = ActiveRecord::Base.connection.execute("SELECT * FROM CTOPORDER where unicode = '#{params['code'].to_s}'")
        result.each do |i|
          answer = 'false'
        end
        render :json => {'result' => answer}
    end

    def checkCode2
        client = ActiveRecord::Base.connection
        jarow = FuzzyStringMatch::JaroWinkler.create( :native )
        answer = 'true'
        code_value = params['code'].to_s.upcase
        barcode_html = params['barcode'].to_s.split(' ').join('')
        option_value = params['option'].to_s.split('/')[1..-1].join(' ')
        barcode = ''
        barcode_array = Array.new
        if code_value.to_s.split(' ').join('') == ''

        else
            result = client.execute("SELECT * FROM PRODUCT where procode = '#{code_value}'")
            pro_type = ''
            result.each do |i|
                pro_type = i[6]
            end
            if pro_type.to_s == ''

            elsif pro_type.to_s == '어그'
                if code_value == "OB755"
                    
                else
                    result2 = client.execute("SELECT * FROM CTOPOPTION2 where proId = '#{code_value}'")
                    db_option_datas = Array.new
                    result2.each do |db_row|
                        db_option_datas << db_row
                    end
                    rate = 0
                    sel_option = ''
                    db_option_datas.each do |option_data|
                        rate2 = jarow.getDistance(option_value, option_data[4].to_s)
                        if rate2 > rate
                            rate = rate2
                            sel_option = option_data[4].to_s
                        end
                    end

                    db_option_datas.each do |option_data|
                        if sel_option == option_data[4].to_s
                            barcode_array << [option_data[2].to_s + '  ' + sel_option.to_s + '  ' + option_data[5].to_s, option_data[2].to_s]
                            option_a = option_robot(option_value)
                            option_b = option_robot(option_data[5].to_s)
                            if option_a != 'no'
                                if option_a == option_b
                                    barcode = option_data[2].to_s
                                end
                            end
                        end
                    end
                

                    if barcode.to_s.split(' ').join('') == ''
                        result8 = client.execute("SELECT barcode FROM CTOPORDER where productName = '#{params['option'].to_s}'")
                        result8.each do |db_row|
                            barcode = db_row[0]
                        end
                    end
                end
            else
                if barcode_html == '카쿠'
                    result2 = client.execute("SELECT * FROM CTOPOPTION2 where proId = '#{code_value}' and (optName1 like '%카쿠%' or optName2 like '%카쿠%')")
                    result2.each do |db_row|
                        barcode = db_row[2]
                    end
                else
                    if code_value == "BSR"
                      code_value = "KO-BEL-SERUM50"
                    end
                    for ccc22 in 2..6
                      if code_value == "BSR-0"+ccc22.to_s
                        code_value = "KO-BEL-SERUM50-0"+ccc22.to_s
                      end
                    end
                    if code_value == "BSR-10"
                      code_value = "KO-BEL-SERUM50-10"
                    end
                    result2 = client.execute("SELECT * FROM CTOPOPTION2 where proId = '#{code_value}'")
                    result2.each do |db_row|
                        if db_row[4].include?('카쿠') or db_row[5].include?('카쿠') or db_row[2].to_s == '89343202002665' 

                        else
                            barcode = db_row[2]
                            break
                        end
                    end
                end
            end
        end
        render :json => {'result' => answer, 'barcode' => barcode, 'list' => barcode_array}
    end

    def order_save
        client = ActiveRecord::Base.connection
        answer = 'ok'
        begin
            td_list = Array.new
            html = params['code'].to_s
            if html.include?('<button')
                answer = 'no'
            else
                html.split('<td')[1..-1].each do |td|
                    row = td.to_s.split('</td>')[0].split('>')[-1]
                    td_list << row
                end

                if td_list[0].to_s.split(' ').join('') == ''
                    answer = 'no'
                else
                    qq = 'select * from CTOPOPTION2 where barcode = "'+td_list[0].to_s+'"'
                    result = client.execute(qq)
                    current_counter = '100'
                    kaku_check = ''
                    procode = ''
                    result.each do |db_data|
                        procode = db_data[1]
                        current_counter = db_data[11].to_s
                        kaku_check = db_data[4].to_s + ' ' + db_data[5].to_s
                    end



                    if current_counter == '-50'
                        puts '품절'
                        answer = 'no'
                    else
                        if procode != ''
                            m = Hash.new
                            m['date1'] = Time.now.to_s.split(' ')[0]
                            m['date2'] = td_list[26]
                            m['date3'] = ''
                            m['name1'] = td_list[2].to_s.split('-')[0]
                            m['market1'] = td_list[2].to_s.split('-')[1].to_s
                            m['date4'] = ''
                            m['deliNo'] = ''
                            m['code1'] = ''
                            m['unicode'] = td_list[9]
                            m['code2'] = td_list[10]
                            m['procode'] = procode
                            m['barcode'] = td_list[0]
                            m['con1'] = ''
                            m['optcon'] = td_list[7]
                            m['ordName'] = td_list[25]
                            m['ordTel'] = td_list[19]
                            m['getName'] = td_list[12]
                            m['getTel'] = td_list[18]
                            m['pnum'] = td_list[14]
                            m['enum'] = td_list[15]
                            m['home'] = td_list[16]
                            m['messege'] = td_list[17]
                            m['che1'] = ''
                            m['moneyNum'] = ''
                            m['money1'] = td_list[22]
                            m['money2'] = td_list[23]
                            m['money3'] = ''
                            m['money4'] = ''
                            m['moneyDate'] = ''
                            m['money5'] = ''
                            m['money6'] = ''
                            if kaku_check.include?('카쿠') or td_list[0].to_s == '89343202002665'
                                m['productName'] = td_list[21] + ' 카쿠'
                            else
                                m['productName'] = td_list[21]
                            end
                            begin
                                api_result = money_api(m['pnum'], m['ordName'], m['ordTel'])
                                if api_result == '1'
                                    m['api_result'] = '정상(주문자)'
                                elsif api_result == '2'
                                    m['api_result'] = '정상(주문자휴대폰불일치)'
                                else
                                    api_result = money_api(m['pnum'], m['getName'], m['getTel'])
                                    if api_result == '1'
                                        m['api_result'] = '정상(수령자)'
                                    elsif api_result == '2'
                                        m['api_result'] = '정상(수령자휴대폰불일치)'
                                    else
                                        m['api_result'] = '개통부오류'
                                    end
                                end
                            rescue => e
                                m['api_result'] = 'api_error'
                            end

                            m2 = m.values
                            m2 = m2.map do |i|
                                '"'+i.to_s+'"'
                            end

                            q = 'insert into CTOPORDER('+m.keys.join(',')+') values('+m2.join(',')+')'
                            client.execute(q)
                        end
                    end
                end
            end
        rescue => e
            puts e
            answer = 'no'
        end

        render :json => {'result' => answer}
    end

    def option_robot(option)
        option = option.split(',')[-1]
        option = option.split(' ')[-1]
        option = option.split(':')[-1]
        option = option.split(';')[-1]
        size_korea2 = [225, 230, 235, 240, 245, 250, 255, 260, 265, 270, 275, 280]
        size_eu = [34,35,36,37,38,39,40,41,42,43,44,45]
        size_hoju = [3,4,5,6,7,8,9,10,11,12,13,14]
        size_string = ['S','M','L','XL','XXL']
        size_579 = ['5','7','9','11','13']
        size_korea = Hash.new
        size_hoju.each_with_index do |i,index|
            size_korea[size_korea2[index].to_s] = i.to_s
        end

        answer = 'no'
        option = option.strip
        if option.include?('(')
            if option.split('(').length > 2
                text2 = option.split(' ')[-1]
            end
            text2 = option.split('(')[0].strip
            if search_number(text2)
                if text2.include?('M')
                    answer = (text2.split('M').join('').to_i+2).to_s
                elsif text2.include?('L')
                    answer = text2.split('L').join('')
                elsif text2.include?('/')
                    answer = text2.split('/')[0]
                else
                    if text2.include?('-')
                        text2 = text2.split('-')[-1]
                    end

                    if text2.to_i > 20
                        size_eu.each_with_index do |size2, index|
                            if size2.to_s == text2
                                answer = size_hoju[index].to_s
                            end
                        end
                    else
                        answer = text2
                    end
                end
            else
                size_string.each_with_index do |size, index|
                    if size == text2
                        answer = size_579[index]
                    end
                end
            end
        else
            text2 = option
            if search_korea_size(text2)
                answer_number = ''
                for number in 200..350
                    if text2.include?(number.to_s)
                        answer_number = number.to_s
                    end
                end

                if answer_number != ''
                    size_korea2.each_with_index do |size5, index|
                        if size5.to_s == answer_number
                            answer = size_hoju[index].to_s
                        end
                    end
                end
            elsif search_number(text2)
                if text2.include?('/')
                    text2 = text2.split('/')[0]
                    if text2.include?('M')
                        text2 = text2.split('M').join('')
                        text2 = (text2.to_i + 2).to_s
                    elsif text2.include?('L')
                        text2 = text2.split('L').join('')
                    end

                    answer = text2
                elsif text2.include?('-')
                    answer = text2.split('-')[0]
                elsif text2.include?('L')
                    answer = text2.split('L').join('')
                elsif text2.include?('M')
                    answer = (text2.split('M').join('').to_i + 2).to_s
                else
                    if text2.include?('-')
                        text2 = text2.split('-')[-1]
                    end

                    if text2.to_i > 20
                        size_eu.each_with_index do |size2, index|
                        if size2.to_s == text2
                            answer = size_hoju[index].to_s
                        end
                        end
                    else
                        answer = text2
                    end
                end
            else
                size_string.each_with_index do |size3, index|
                    if size3 == text2.strip
                        answer = size_579[index]
                    end
                end
            end
        end

        return answer
    end

    #발주서다운로드
    def download_action7
        begin
			column_name = Array.new
			column_name << '회원명'
			column_name << '브랜드명'
			column_name << '고도몰상품코드'
			column_name << '옵션코드'
			column_name << '상품명'
			column_name << '옵션명'
			column_name << '상품수량'
			column_name << '오픈마켓 원주문번호(선택)'
			column_name << '비고1(선택)'
			column_name << '비고2(선택)'
			column_name << '수취인이름'
			column_name << '수취인 핸드폰 번호'
			column_name << '개인통관고유부호'
			column_name << '수취인 우편번호'
			column_name << '수취인 전체주소'
			column_name << '주문시 남기는 글'
			data = params['data']

			where_country = params['where3']
            client = ActiveRecord::Base.connection
            book = Spreadsheet::Workbook.new
            sheet1 = book.create_worksheet
            company = params['where'].to_s
            index = 0

			sheet1.column(4).width = 50
			sheet1.column(14).width = 50

			column_name.each do |col_name|
			  	sheet1.row(0).push(col_name)
			end

			sheet1.row(0).

            data.each_with_index do |i,index2|
                data2 = Array.new
                i.split('<td')[1..-1].each do |k|
                    data2 << k.split('</td>')[0].to_s.split('>')[1].to_s
                end
                if data2[3].to_s.split(' ').join('') == '' or params['where2'].to_s == '강제다운로드'
                    if data2[4].to_s == company
                        barcode = data2[12]
                        procode = data2[11]
                        godocode = ''
                        opt = ''
                        opt_con = 1
                        opt_code = ''
                        pro_name = ''
                        brand_name = ''
                        pro_type = ''
                        pro_where = ''
                        if ['01','02','03','04','05','06'].include?(procode.to_s.split('-')[-1].to_s)
	                        procode = procode.split('-')[0..-2].join('-')
                        end
                        if procode == 'NT-LUNG'
                            procode = 'RT-NT-LUNG'
                        end
                        result = client.execute("select brandName, godocode, proName, proType, name1 from PRODUCT where procode = '#{procode.to_s}'")
                        result.each do |i|
							brand_name = i[0].to_s
							godocode = i[1].to_s
							pro_name = i[2].to_s
							pro_type = i[3].to_s
							pro_where = i[4].to_s
							break
                        end
                        if pro_type == '어그'
							result = client.execute("select optName1,optCode,optCon from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
							result.each do |i|
								opt = i[0].to_s
								opt_code = i[1].to_s
							end
                        else
							result = client.execute("select optName1, optCode, optCon from CTOPOPTION2 where barcode = '#{barcode.to_s.split('-')[0]}'")
							result.each do |i|
								opt = i[0].to_s
								opt_code = i[1].to_s
							end
                        end
                        result = client.execute("select optCon from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
                        result.each do |i|
	                        opt_con = i[0].to_i
                        end

                        # if pro_where == where_country or (where_country == '호주' and pro_where != '한국' and pro_where != '중국')
                        if true
							pro_con = (opt_con.to_i * data2[14].to_i).to_s
							sheet1.row(index+1).push(data2[4].to_s+'-'+data2[5].to_s) #회원명
							sheet1.row(index+1).push(brand_name) #브랜드명
							sheet1.row(index+1).push(godocode)
							sheet1.row(index+1).push(opt_code) #옵션코드
							sheet1.row(index+1).push(pro_name)
							sheet1.row(index+1).push(godocode)
							sheet1.row(index+1).push(pro_con) #상품수량
							sheet1.row(index+1).push(data2[10].to_s) #오픈마켓 원주문번호
							sheet1.row(index+1).push(data2[10].to_s) #비고1
							sheet1.row(index+1).push('') #비고2
							port_number_status = data2[33].to_s
							if port_number_status.include?('정상')
								if port_number_status.include?('주문자')
									sheet1.row(index+1).push(data2[15].to_s)
									sheet1.row(index+1).push(data2[16].to_s)
								else
									sheet1.row(index+1).push(data2[17].to_s)
									sheet1.row(index+1).push(data2[18].to_s)
								end
							else
								sheet1.row(index+1).push(data2[15].to_s) #수취인이름
								sheet1.row(index+1).push(data2[16].to_s) #수취인 핸드폰 번호
							end

							sheet1.row(index+1).push(data2[19]) #개인통관고유부호
							sheet1.row(index+1).push(data2[20]) #수취인 우편번호
							sheet1.row(index+1).push(data2[21]) #수취인 전체주소
							sheet1.row(index+1).push(data2[22]) #주문시 남기는 글
							index += 1
							time_text = Time.now.to_s.split(' ')[0]
							client.execute("update CTOPORDER set download1 = '#{time_text}', date3 = '#{time_text}' where _id = #{data2[0].to_s}")
                        end
                    end
                end
            end
            where = params['where'].to_s
            path = './public/excel/'+Time.now.to_i.to_s+'-'+session[:id].to_s+'-'+where+'.xls'
            book.write path

            render :json => {'result' => 'ok' , 'answer' => path.split('./public')[1]}
        rescue => e
            puts 'error ==> ' + e.to_s
            render :json => {'result' => 'no'}
        end
	end

	def download_kacu
	  data = params['data']
	  time_dd = Time.now.to_s.split(' ')[0].split('-').join('')
	  dir_name = './public/excel/'+time_dd
	  if Dir.exist?(dir_name)
		Dir.delete(dir_name)
	  end
	  Dir.mkdir(dir_name)
	  file_name = Array.new
	  ['CTOP','FC','UM','TP','VM','MDD', 'CNC', 'MP'].each do |company_name|
		file_name << download_action_multi(company_name, data, params['where2'].to_s)
	  end
	  dir_name2 = dir_name+'-카쿠.zip'
	  puts dir_name2
	  Zip::File.open(dir_name2, Zip::File::CREATE) do |zipfile|
		file_name.each do |file|
		  zipfile.add(File.basename(file), file)
		end
	  end

	  render :json => {'result' => 'ok' , 'answer' => dir_name2.split('./public')[1]}
	end

	def download_action_all
		data = params['data']
		time_dd = Time.now.to_s.split(' ')[0].split('-').join('')
		dir_name = './public/excel/'+time_dd

		if Dir.exist?(dir_name)
            file_list = Dir.entries(dir_name)
            file_list.each do |file|
                if file == '.' or file == '..'

                else
                    File.open(dir_name+'/'+file, 'r') do |f|
                        File.delete(f)
                    end
                end
            end
			Dir.delete(dir_name)
		end
		begin
			Dir.mkdir(dir_name)
		rescue

		end

		file_name = Array.new
		where3 = params['where3'].to_s
        if where3.include?("B2B")
                file_name << download_action_multi2("B2B", data, params['where2'].to_s, where3)
        else
            ['CTOP','FC','UM','TP','VM','MDD','CNC','MP', 'CR'].each do |company_name|
                file_name << download_action_multi2(company_name, data, params['where2'].to_s, where3)
            end
        end
        if where3 == '한국' or where3 == '카쿠'
            begin
                file_name << korea_excel_make(data, where3)
            rescue => e
                puts '한국통합엑셀만드는중 에러...'
                puts e
            end
        end
		dir_name2 = dir_name+'-'+where3+'.zip'
        begin
            File.open(dir_name2, 'r') do |f|
                File.delete(f)
            end
        rescue

        end
		Zip::File.open(dir_name2, Zip::File::CREATE) do |zipfile|
			file_name.each do |file|
                begin
				    zipfile.add(File.basename(file), file)
                rescue => e
                    puts '압축도중에러...'
                    puts e
                end
			end
		end

		render :json => {'result' => 'ok' , 'answer' => dir_name2.split('./public')[1]}
	end

    def edit_action2
        begin
            client = ActiveRecord::Base.connection
            row = params['data']
            data2 = Array.new
            row.each do |i|
                begin
                    db_id = i.split('<td>')[1].split('</td>')[0]
                    i.split('<td')[1..-1].each do |k|
                        data2 << k.split('</td>')[0].split('>')[1]
                    end

                    m = Hash.new
                    m['date1'] = data2[1]
                    m['date2'] = data2[2]
                    m['date3'] = data2[3]
                    m['name1'] = data2[4]
                    m['market1'] = data2[5]
                    m['date4'] = data2[6]
                    m['deliNo'] = data2[7]
                    m['code1'] = data2[8]
                    m['unicode'] = data2[9]
                    m['code2'] = data2[10]
                    m['procode'] = data2[11]
                    m['barcode'] = data2[12]
                    m['con1'] = data2[13]
                    m['optcon'] = data2[14]
                    m['ordName'] = data2[15]
                    m['ordTel'] = data2[16]
                    m['getName'] = data2[17]
                    m['getTel'] = data2[18]
                    m['pnum'] = data2[19]
                    m['enum'] = data2[20]
                    m['home'] = data2[21]
                    m['messege'] = data2[22]
                    m['che1'] = data2[23]
                    m['moneyNum'] = data2[24]
                    m['money1'] = data2[25]
                    m['money2'] = data2[26]
                    m['money3'] = data2[27]
                    m['money4'] = data2[28]
                    m['moneyDate'] = data2[29]
                    m['money5'] = data2[30]
                    m['money6'] = data2[31]
                    begin
                        api_result = money_api(m['pnum'], m['ordName'], m['ordTel'])
                        if api_result == '1'
                            m['api_result'] = '정상(주문자)'
                        elsif api_result == '2'
                            m['api_result'] = '정상(주문자휴대폰불일치)'
                        else
                            api_result = money_api(m['pnum'], m['getName'], m['getTel'])
                            if api_result == '1'
                                m['api_result'] = '정상(수령자)'
                            elsif api_result == '2'
                                m['api_result'] = '정상(수령자휴대폰불일치)'
                            else
                                m['api_result'] = '개통부오류'
                            end
                        end
                    rescue => e
                        m['api_result'] = 'api_error'
                        puts e
                    end
                    m2 = Array.new
                    m.each do |key,value|
                        m2 << key + ' = "' + value.to_s.split('"').join('') + '"'
                    end

                    q = "update CTOPORDER set #{m2.join(',')} where _id = " + db_id.to_s
                    client.execute(q)
                rescue => e
                    puts e
                end
            end
            render :json => {'result' => 'ok'}
        rescue
            render :json => {'result' => 'no'}
        end
    end

    def total_download
        dir_name2 = './public/excel/'+Time.now.to_i.to_s+'.xls'
        client = ActiveRecord::Base.connection
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet
        data = params['data']
        data.each_with_index do |i,index2|
			data2 = Array.new
			i.split('<td')[1..-1].each do |k|
			  	data2 << k.split('</td>')[0].split('>')[1]
			end

            data2.each_with_index do |ixx, index2xx|
                sheet1.row(index2+1).push(data2[index2xx])
            end
        end

        book.write dir_name2

        render :json => {'result' => 'ok' , 'answer' => dir_name2.split('./public')[1]}
    end

    def total_download333
        client = ActiveRecord::Base.connection
        data = params['data']
        dir_name2 = './public/excel/'+Time.now.to_i.to_s+'(기존양식).xls'
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet
        column_name = Array.new
        column_name << 'ID'         #0
        column_name << '업체정보'   #1
        column_name << '공급 방식'  #2
        column_name << '작성일'     #3
        column_name << '주문일'     #4
        column_name << '발주일'     #5
        column_name << '업체명'     #6
        column_name << '마켓명'     #7
        column_name << '출고일'     #8
        column_name << '송장번호'   #9
        column_name << '도매주문번호'#10
        column_name << '소매비젬번호'#11
        column_name << '소매주문번호'#12
        column_name << '출고 국가'  #13
        column_name << '바코드'     #14
        column_name << '상품코드'   #15
        column_name << '브랜드'     #16
        column_name << '상품명'     #17
        column_name << '옵션1'      #18
        column_name << '옵션2'      #19
        column_name << '수량'#20
        column_name << '주문자명'#21
        column_name << '주문자 핸드폰번호'#22
        column_name << '수령자명'#23
        column_name << '수취인 핸드폰번호'#24
        column_name << '개통부'#25
        column_name << '우편번호'#26
        column_name << '주소'#27
        column_name << '배송메세지'#28
        column_name << 'CS1'#29
        column_name << '담당자1'#30
        column_name << 'CS2'#31
        column_name << '담당자2'#32
        column_name << 'CS3'#33
        column_name << '담당자3'#34
        column_name << '품절여부'#35
        column_name << '변경'#36
        column_name << '출고전 취소'#37
        column_name << '출고후 취소'#38
        column_name << '취소후 구매'#39
        column_name << '수령후 반품'#40
        column_name << '정산후 반품'#41
        column_name << '회수여부'#42
        column_name << '1차 발송지연일'#43
        column_name << '1차 지연마감일'#44
        column_name << '발송담당자1'#45
        column_name << '2차 발송지연일'#46
        column_name << '처리방향'#47
        column_name << '발송담당자2'#48
        column_name << '입금계좌'#49
        column_name << '판매가'#50
        column_name << '배송비'#51
        column_name << '수수료'#52
        column_name << '정산금액'#53
        column_name << '정산확정일'#54
        column_name << '원가'#55
        column_name << '배송비'#56
        index = 0
        column_name.each do |col_name|
            sheet1.row(0).push(col_name)
        end

        data.each_with_index do |i,index2|
            data2 = Array.new
			i.split('<td')[1..-1].each do |k|
			  	data2 << k.split('</td>')[0].split('>')[1]
			end

            barcode = data2[12].to_s.split(' ').join('')
            procode = data2[11].to_s.split(' ').join('')
            godocode = ''
            opt = ''
            opt2 = ''
            opt_con = 1
            opt_code = ''
            pro_name = data2[32].to_s
            db_pro_name = ''
            brand_name = ''
            pro_type = ''
            pro_where = ''
            price1 = ''
            price2 = ''
            if ['01','02','03','04','05','06'].include?(procode.to_s.split('-')[-1].to_s)
                procode = procode.split('-')[0..-2].join('-')
            end
            result = client.execute("select brandName, godocode, proName, proType, name1 from PRODUCT where procode = '#{procode.to_s}'")
            result.each do |i2|
                brand_name = i2[0].to_s
                godocode = i2[1].to_s
                db_pro_name = i2[2].to_s
                pro_type = i2[3].to_s
                pro_where = i2[4].to_s
                break
            end
            opt_con22 = '100'
            if pro_type == '어그'
                result = client.execute("select optName1,optCode,optCon, curCon, optName2 from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
                result.each do |i3|
                    opt = i3[0].to_s
                    opt_code = i3[1].to_s
                    opt_con22 = i3[3].to_s
                    opt2 = i3[4].to_s
                end
            else
                result = client.execute("select optName1, optCode, optCon, curCon, optName2  from CTOPOPTION2 where barcode = '#{barcode.to_s.split('-')[0]}'")
                result.each do |i4|
                    opt = i4[0].to_s
                    opt_code = i4[1].to_s
                    opt_con22 = i4[3].to_s
                    opt2 = i4[4].to_s
                end
            end
            result = client.execute("select optCon, optName2, price, priceDel from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
            result.each do |i5|
                opt_con = i5[0].to_i
                opt2 = i5[1].to_s
                price1 = i5[2].to_s
                price2 = i5[3].to_s
            end

            opt_value = (opt_con.to_i * data2[14].to_i).to_s

            if true
                if false

                else
                    if true
                        sheet1.row(index+1).push('')#0
                        sheet1.row(index+1).push(data2[4].to_s+'-'+data2[5].to_s)#1
                        sheet1.row(index+1).push('사입')
                        sheet1.row(index+1).push(data2[1])#2
                        sheet1.row(index+1).push(data2[2])#3
                        sheet1.row(index+1).push(data2[3])#4
                        sheet1.row(index+1).push(data2[4])#5
                        sheet1.row(index+1).push(data2[5])#6
                        sheet1.row(index+1).push(data2[6])#7
                        sheet1.row(index+1).push(data2[7])#8
                        sheet1.row(index+1).push(data2[8])#9
                        sheet1.row(index+1).push(data2[9])#10
                        sheet1.row(index+1).push(data2[10])#11
                        sheet1.row(index+1).push(pro_where)#12
                        sheet1.row(index+1).push(barcode.to_s)#13 출고 국가
                        sheet1.row(index+1).push(data2[11])#14 바코드
                        sheet1.row(index+1).push(brand_name)#15 상품코드
                        sheet1.row(index+1).push(db_pro_name)#16 브랜드
                        sheet1.row(index+1).push(opt)#17 상품명
                        sheet1.row(index+1).push(opt2)#18 옵션1
                        sheet1.row(index+1).push(opt_value)#19 옵션2
                        sheet1.row(index+1).push(data2[15])#20 수량
                        sheet1.row(index+1).push(data2[16])#21 주문자명
                        sheet1.row(index+1).push(data2[17])#22 주문자 핸드폰번호
                        sheet1.row(index+1).push(data2[18])#23 수령자명
                        sheet1.row(index+1).push(data2[19])#24 수취인 핸드폰번호
                        sheet1.row(index+1).push(data2[20])#25 개통부
                        sheet1.row(index+1).push(data2[21])#26 우편번호
                        sheet1.row(index+1).push(data2[22])#27 주소
                        sheet1.row(index+1).push(data2[23])#28 배송메세지
                        sheet1.row(index+1).push('')#29 CS1
                        sheet1.row(index+1).push('')#30 담당자1
                        sheet1.row(index+1).push('')#31 CS2
                        sheet1.row(index+1).push('')#32 담당자2
                        sheet1.row(index+1).push('')#33 CS3
                        sheet1.row(index+1).push('')#34 담당자3
                        sheet1.row(index+1).push('')#35 품절여부
                        sheet1.row(index+1).push('')#36 변경
                        sheet1.row(index+1).push('')#37 출고전취소
                        sheet1.row(index+1).push('')#39 취소후구매
                        sheet1.row(index+1).push('')#40 수령후반품
                        sheet1.row(index+1).push('')#41 정산후반품
                        sheet1.row(index+1).push('')#42 회수여부
                        sheet1.row(index+1).push('')#43 1차 발송지연일
                        sheet1.row(index+1).push('')#44 1차 지연마감일
                        sheet1.row(index+1).push('')#45 발송담당자1
                        sheet1.row(index+1).push('')#46 2차발송지연일
                        sheet1.row(index+1).push('')#47 처리방향
                        sheet1.row(index+1).push('')#48 발송담당자2
                        sheet1.row(index+1).push('')#49 입금계좌
                        sheet1.row(index+1).push(data2[25])#50 판매가
                        sheet1.row(index+1).push(data2[26])#51 배송비
                        sheet1.row(index+1).push('')#52 수수료
                        sheet1.row(index+1).push('')#53 정산금액
                        sheet1.row(index+1).push('')#54 정산확정일
                        sheet1.row(index+1).push(price1)#55 원가
                        sheet1.row(index+1).push(price2)#56 배송비
                        index += 1
                    end
                end
            end
        end

        book.write dir_name2

        render :json => {'result' => 'ok' , 'answer' => dir_name2.split('./public')[1]}
    end

    def total_download2
        dir_name2 = './public/excel/'+Time.now.to_i.to_s+'.xls'
        client = ActiveRecord::Base.connection
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet
        index = 0
        today = Time.now.to_s.split(' ')[0]
        data = Array.new
        result = client.execute('select deliNo, unicode, bin1, _id  from CTOPORDER where date4 = "'+today+'"')
        result.each do |db_data|
            data << db_data
        end
        data.each do |data2|
            if data2[2].to_s == ''
                sheet1.row(index).push(data2[0].to_s)
                sheet1.row(index).push(data2[1].to_s)
                index += 1
                client.execute('update CTOPORDER set bin1 = "'+today+'" where _id = '+data2[3].to_s)
            end
        end
        # data = params['data']
        # index = 0
        # data.each_with_index do |i,index2|
		# 	data2 = Array.new
		# 	i.split('<td')[1..-1].each do |k|
		# 	  	data2 << k.split('</td>')[0].split('>')[1]
		# 	end
            
        #     if data2[7].to_s.split(' ').join('') == '' or data2[7].to_s.split(' ').join('') == '출고전취소'

        #     else
        #         sheet1.row(index).push(data2[7])
        #         sheet1.row(index).push(data2[9])
        #         index += 1
        #     end
        # end

        book.write dir_name2

        render :json => {'result' => 'ok' , 'answer' => dir_name2.split('./public')[1]}
    end

    def korea_excel_make(data, where3)
        time_dd = Time.now.to_s.split(' ')[0].split('-').join('')
        client = ActiveRecord::Base.connection
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet
        column_name = Array.new
        column_name << 'ID'         #0
        column_name << '업체정보'   #1
        column_name << '공급 방식'  #2
        column_name << '작성일'     #3
        column_name << '주문일'     #4
        column_name << '발주일'     #5
        column_name << '업체명'     #6
        column_name << '마켓명'     #7
        column_name << '출고일'     #8
        column_name << '송장번호'   #9
        column_name << '도매주문번호'#10
        column_name << '소매비젬번호'#11
        column_name << '소매주문번호'#12
        column_name << '출고 국가'  #13
        column_name << '바코드'     #14
        column_name << '상품코드'   #15
        column_name << '브랜드'     #16
        column_name << '상품명'     #17
        column_name << '옵션1'      #18
        column_name << '옵션2'      #19
        column_name << '수량'#20
        column_name << '주문자명'#21
        column_name << '주문자 핸드폰번호'#22
        column_name << '수령자명'#23
        column_name << '수취인 핸드폰번호'#24
        column_name << '개통부'#25
        column_name << '우편번호'#26
        column_name << '주소'#27
        column_name << '배송메세지'#28
        column_name << 'CS1'#29
        column_name << '담당자1'#30
        column_name << 'CS2'#31
        column_name << '담당자2'#32
        column_name << 'CS3'#33
        column_name << '담당자3'#34
        column_name << '품절여부'#35
        column_name << '변경'#36
        column_name << '출고전 취소'#37
        column_name << '출고후 취소'#38
        column_name << '취소후 구매'#39
        column_name << '수령후 반품'#40
        column_name << '정산후 반품'#41
        column_name << '회수여부'#42
        column_name << '1차 발송지연일'#43
        column_name << '1차 지연마감일'#44
        column_name << '발송담당자1'#45
        column_name << '2차 발송지연일'#46
        column_name << '처리방향'#47
        column_name << '발송담당자2'#48
        column_name << '입금계좌'#49
        column_name << '판매가'#50
        column_name << '배송비'#51
        column_name << '수수료'#52
        column_name << '정산금액'#53
        column_name << '정산확정일'#54
        column_name << '원가'#55
        column_name << '배송비'#56

        index = 0
        column_name.each do |col_name|
            sheet1.row(0).push(col_name)
        end

        data.each_with_index do |i,index2|
            data2 = Array.new
			i.split('<td')[1..-1].each do |k|
			  	data2 << k.split('</td>')[0].split('>')[1]
			end

            barcode = data2[12].to_s.split(' ').join('')
            procode = data2[11].to_s.split(' ').join('')
            godocode = ''
            opt = ''
            opt2 = ''
            opt_con = 1
            opt_code = ''
            pro_name = data2[32].to_s
            db_pro_name = ''
            brand_name = ''
            pro_type = ''
            pro_where = ''
            price1 = ''
            price2 = ''
            if ['01','02','03','04','05','06'].include?(procode.to_s.split('-')[-1].to_s)
                procode = procode.split('-')[0..-2].join('-')
            end
            result = client.execute("select brandName, godocode, proName, proType, name1 from PRODUCT where procode = '#{procode.to_s}'")
            result.each do |i2|
                brand_name = i2[0].to_s
                godocode = i2[1].to_s
                db_pro_name = i2[2].to_s
                pro_type = i2[3].to_s
                pro_where = i2[4].to_s
                break
            end
            opt_con22 = '100'
            if pro_type == '어그'
                result = client.execute("select optName1,optCode,optCon, curCon, optName2 from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
                result.each do |i3|
                    opt = i3[0].to_s
                    opt_code = i3[1].to_s
                    opt_con22 = i3[3].to_s
                    opt2 = i3[4].to_s
                end
            else
                result = client.execute("select optName1, optCode, optCon, curCon, optName2  from CTOPOPTION2 where barcode = '#{barcode.to_s.split('-')[0]}'")
                result.each do |i4|
                    opt = i4[0].to_s
                    opt_code = i4[1].to_s
                    opt_con22 = i4[3].to_s
                    opt2 = i4[4].to_s
                end
            end
            result = client.execute("select optCon, optName2, price, priceDel from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
            result.each do |i5|
                opt_con = i5[0].to_i
                opt2 = i5[1].to_s
                price1 = i5[2].to_s
                price2 = i5[3].to_s
            end

            opt_value = (opt_con.to_i * data2[14].to_i).to_s

            if pro_where == '한국' or procode.to_s == 'DK888' or barcode.to_s == '89343202002665' or ((opt+' '+opt2).include?('카쿠') and pro_where = '호주')
                if opt_con22.to_s == '0' or pro_type == "상품권"

                else
                  if where3 == '한국' or ((where3 == '카쿠' and (opt+' '+opt2).include?('카쿠')) or  barcode.to_s == '89343202002665' or barcode.to_s.include?('카쿠'))
                        sheet1.row(index+1).push('')#0
                        sheet1.row(index+1).push(data2[4].to_s+'-'+data2[5].to_s)#1
                        sheet1.row(index+1).push('사입')
                        sheet1.row(index+1).push(data2[1])#2
                        sheet1.row(index+1).push(data2[2])#3
                        sheet1.row(index+1).push(data2[3])#4
                        sheet1.row(index+1).push(data2[4])#5
                        sheet1.row(index+1).push(data2[5])#6
                        sheet1.row(index+1).push(data2[6])#7
                        sheet1.row(index+1).push(data2[7])#8
                        sheet1.row(index+1).push(data2[8])#9
                        sheet1.row(index+1).push(data2[9])#10
                        sheet1.row(index+1).push(data2[10])#11
                        sheet1.row(index+1).push(pro_where)#12
                        sheet1.row(index+1).push(barcode.to_s)#13 출고 국가
                        sheet1.row(index+1).push(data2[11])#14 바코드
                        sheet1.row(index+1).push(brand_name)#15 상품코드
                        sheet1.row(index+1).push(db_pro_name)#16 브랜드
                        sheet1.row(index+1).push(opt)#17 상품명
                        sheet1.row(index+1).push(opt2)#18 옵션1
                        sheet1.row(index+1).push(opt_value)#19 옵션2
                        sheet1.row(index+1).push(data2[15])#20 수량
                        sheet1.row(index+1).push(data2[16])#21 주문자명
                        sheet1.row(index+1).push(data2[17])#22 주문자 핸드폰번호
                        sheet1.row(index+1).push(data2[18])#23 수령자명
                        sheet1.row(index+1).push(data2[19])#24 수취인 핸드폰번호
                        sheet1.row(index+1).push(data2[20])#25 개통부
                        sheet1.row(index+1).push(data2[21])#26 우편번호
                        sheet1.row(index+1).push(data2[22])#27 주소
                        sheet1.row(index+1).push(data2[23])#28 배송메세지
                        sheet1.row(index+1).push('')#29 CS1
                        sheet1.row(index+1).push('')#30 담당자1
                        sheet1.row(index+1).push('')#31 CS2
                        sheet1.row(index+1).push('')#32 담당자2
                        sheet1.row(index+1).push('')#33 CS3
                        sheet1.row(index+1).push('')#34 담당자3
                        sheet1.row(index+1).push('')#35 품절여부
                        sheet1.row(index+1).push('')#36 변경
                        sheet1.row(index+1).push('')#37 출고전취소
                        sheet1.row(index+1).push('')#39 취소후구매
                        sheet1.row(index+1).push('')#40 수령후반품
                        sheet1.row(index+1).push('')#41 정산후반품
                        sheet1.row(index+1).push('')#42 회수여부
                        sheet1.row(index+1).push('')#43 1차 발송지연일
                        sheet1.row(index+1).push('')#44 1차 지연마감일
                        sheet1.row(index+1).push('')#45 발송담당자1
                        sheet1.row(index+1).push('')#46 2차발송지연일
                        sheet1.row(index+1).push('')#47 처리방향
                        sheet1.row(index+1).push('')#48 발송담당자2
                        sheet1.row(index+1).push('')#49 입금계좌
                        sheet1.row(index+1).push(data2[25])#50 판매가
                        sheet1.row(index+1).push(data2[26])#51 배송비
                        sheet1.row(index+1).push('')#52 수수료
                        sheet1.row(index+1).push('')#53 정산금액
                        sheet1.row(index+1).push('')#54 정산확정일
                        sheet1.row(index+1).push(price1)#55 원가
                        sheet1.row(index+1).push(price2)#56 배송비
                        index += 1
                    end
                end
            end
        end

        book.write './public/excel/'+time_dd+'/koreaTotal.xls'

        return './public/excel/'+time_dd+'/koreaTotal.xls'
    end

    def kakuSave
        client = ActiveRecord::Base.connection
        client.execute('delete from kaku')
        data = params['data']
        data.each do |i|
            data2 = Array.new
			i.split('<td')[1..-1].each do |k|
			  	data2 << k.split('</td>')[0].split('>')[1]
			end

        end

        render :json => {}
    end

	def download_action_multi2(company_name, data, where2, where3)
	  client = ActiveRecord::Base.connection
	  book = Spreadsheet::Workbook.new
      action_check = 0
	  sheet1 = book.create_worksheet
	  column_name = Array.new
	  if where3 == '호주'
		column_name << '회원명'
		column_name << '브랜드명'
		column_name << '고도몰상품코드'
		column_name << '옵션코드'
		column_name << '상품명'
		column_name << '옵션명'
		column_name << '상품수량'
		column_name << '오픈마켓 원주문번호(선택)'
		column_name << '비고1(선택)'
		column_name << '비고2(선택)'
		column_name << '수취인이름'
		column_name << '수취인 핸드폰 번호'
		column_name << '개인통관고유부호'
		column_name << '수취인 우편번호'
		column_name << '수취인 전체주소'
		column_name << '주문시 남기는 글'

		index = 0

		sheet1.column(4).width = 50
		sheet1.column(14).width = 50

		column_name.each do |col_name|
		  	sheet1.row(0).push(col_name)
		end

		data.each_with_index do |i,index2|
			data2 = Array.new
			i.split('<td')[1..-1].each do |k|
			  	data2 << k.split('</td>')[0].split('>')[1]
			end
			if data2[34].to_s.split(' ').join('') == '' or where2 == '강제다운로드'
				if data2[4].to_s == company_name
					barcode = data2[12]
					procode = data2[11]
					godocode = ''
					opt = ''
                    opt2 = ''
					opt_con = 1
					opt_code = ''
					pro_name = data2[32].to_s
					brand_name = ''
					pro_type = ''
					pro_where = ''
					if ['01','02','03','04','05','06'].include?(procode.to_s.split('-')[-1].to_s)
					  procode = procode.split('-')[0..-2].join('-')
					end
					result = client.execute("select brandName, godocode, proName, proType, name1 from PRODUCT where procode = '#{procode.to_s}'")
					result.each do |i|
					  brand_name = i[0].to_s
					  godocode = i[1].to_s
					  pro_type = i[3].to_s
					  pro_where = i[4].to_s
                      pro_name = i[2]
					  break
					end
                    opt_con22 = '100'
					if pro_type == '어그'
                        result = client.execute("select optName1,optCode,optCon, curCon, optName2 from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
                        result.each do |i|
                            opt = i[0].to_s
                            opt_code = i[1].to_s
                            opt_con22 = i[3].to_s
                            opt2 = i[4].to_s
                            pro_name = pro_name.split(' ')[0..-1].join(' ') + opt + ' ' + opt2
                            break
                        end
					else
                        result = client.execute("select optName1, optCode, optCon, curCon, optName2  from CTOPOPTION2 where barcode = '#{barcode.to_s.split('-')[0]}'")
                        result.each do |i|
                            opt = i[0].to_s
                            opt_code = i[1].to_s
                            opt_con22 = i[3].to_s
                            opt2 = i[4].to_s
                        end
					end
					result = client.execute("select optCon from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
					result.each do |i|
					  opt_con = i[0].to_i
					end

					if pro_where == '한국' or opt_con22 == '0' or pro_type == "상품권" or (opt+' '+opt2).include?('카쿠') or barcode.to_s == '89343202002665'

					else
                        action_check = 1
						pro_con = (opt_con.to_i * data2[14].to_i).to_s
						sheet1.row(index+1).push(data2[4].to_s+'-'+data2[5].to_s) #회원명
						sheet1.row(index+1).push(brand_name) #브랜드명
						sheet1.row(index+1).push(godocode)
						sheet1.row(index+1).push(opt_code) #옵션코드
						sheet1.row(index+1).push(pro_name)
						sheet1.row(index+1).push(godocode)
						sheet1.row(index+1).push(pro_con) #상품수량
						sheet1.row(index+1).push(data2[10].to_s) #오픈마켓 원주문번호
						sheet1.row(index+1).push(data2[10].to_s) #비고1
						sheet1.row(index+1).push('') #비고2
						port_number_status = data2[33].to_s 
						if port_number_status.include?('정상')
						  if port_number_status.include?('주문자')
							sheet1.row(index+1).push(data2[15].to_s)
                                    if data2[16].to_s.include?('0000')
                                        sheet1.row(index+1).push(data2[18].to_s)
                                    else
                                        if data2[16].to_s.include?('010')
                sheet1.row(index+1).push(data2[16].to_s)
                                        else
                                        sheet1.row(index+1).push(data2[18].to_s)
                                        end
                                    end
        else
        sheet1.row(index+1).push(data2[17].to_s)
                                    if data2[18].to_s.include?('0000')
                                        sheet1.row(index+1).push(data2[16].to_s)
                                    else
                                        if data2[18].to_s.include?('010')
                sheet1.row(index+1).push(data2[18].to_s)
                                        else
                                        sheet1.row(index+1).push(data2[16].to_s)
                                        end
                                    end
                            end
                        else
                                if data2[16].to_s.include?('010')
                                    if data2[16].to_s.include?('0000')
                                        sheet1.row(index+1).push(data2[17].to_s)
                                        sheet1.row(index+1).push(data2[18].to_s)
                                    else
                                        sheet1.row(index+1).push(data2[15].to_s)
                                        sheet1.row(index+1).push(data2[16].to_s)
                                    end
                                else
        sheet1.row(index+1).push(data2[17].to_s) #수취인이름
        sheet1.row(index+1).push(data2[18].to_s) #수취인 핸드폰 번호
                                end
						end

						sheet1.row(index+1).push(data2[19]) #개인통관고유부호
						sheet1.row(index+1).push(data2[20]) #수취인 우편번호
						sheet1.row(index+1).push(data2[21]) #수취인 전체주소
						sheet1.row(index+1).push(data2[22]) #주문시 남기는 글
						index += 1
						time_text = Time.now.to_s.split(' ')[0]
						client.execute("update CTOPORDER set download1 = '#{time_text}', date3 = '#{time_text}' where _id = #{data2[0].to_s}")
					end
				end
			end
		end
        elsif where3 == "B2B해외" or where3 == "B2B국내"
            workbook = RubyXL::Workbook.new
            worksheet = workbook[0]
            worksheet.add_cell(0, 0, '브랜드명')
            worksheet.add_cell(0, 1, '상품명')
            worksheet.add_cell(0, 2, '옵션')
            worksheet.add_cell(0, 3, '도매가')
            worksheet.add_cell(0, 4, '배송비')
            worksheet.add_cell(0, 5, '무게')
            worksheet.add_cell(0, 6, '자체상품코드')
            worksheet.add_cell(0, 7, '옵션별바코드')
            worksheet.add_cell(0, 8, '수량')
            if where3 == "B2B해외"
                con7 = 1
                worksheet.add_cell(0, 9, '개인통관부호')
            else
                con7 = 0
            end
            
            ['수취인명','수취인연락처','우편번호','전체주소','배송메세지','오픈마켓원주문번호','비고1','비고2','비고3','비고4','비고5'].each_with_index do |colname, index88|
                worksheet.add_cell(0, 9+index88+con7, colname)
            end

            index = 1

            data.each_with_index do |i,index2|
                data2 = Array.new
                i.split('<td')[1..-1].each do |k|
                    data2 << k.split('</td>')[0].split('>')[1]
                end

                if data2[34].to_s.split(' ').join('') == '' or where2 == '강제다운로드'
                    barcode = data2[12]
                    procode = data2[11]
                    godocode = ''
					opt = ''
                    opt2 = ''
					opt_con = 1
					opt_code = ''
					pro_name = data2[32].to_s
					brand_name = ''
					pro_type = ''
					pro_where = ''
                    if ['01','02','03','04','05','06'].include?(procode.to_s.split('-')[-1].to_s)
                        procode = procode.split('-')[0..-2].join('-')
                    end

                    result = client.execute("select brandName, godocode, proName, proType, name1 from PRODUCT where procode = '#{procode.to_s}'")
					result.each do |i|
                        brand_name = i[0].to_s
                        godocode = i[1].to_s
                        pro_type = i[3].to_s
                        pro_where = i[4].to_s
                        pro_name = i[2]
                        break
					end

                    opt_con22 = '100'
					if pro_type == '어그'
                        result = client.execute("select optName1,optCode,optCon, curCon, optName2 from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
                        result.each do |i|
                            opt = i[0].to_s
                            opt_code = i[1].to_s
                            opt_con22 = i[3].to_s
                            opt2 = i[4].to_s
                            pro_name = pro_name.split(' ')[0..-1].join(' ') + opt + ' ' + opt2
                            break
                        end
					else
                        result = client.execute("select optName1, optCode, optCon, curCon, optName2  from CTOPOPTION2 where barcode = '#{barcode.to_s.split('-')[0]}'")
                        result.each do |i|
                            opt = i[0].to_s
                            opt_code = i[1].to_s
                            opt_con22 = i[3].to_s
                            opt2 = i[4].to_s
                        end
					end
					result = client.execute("select optCon from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
					result.each do |i|
					    opt_con = i[0].to_i
					end

                    if ['01','02','03','04','05','06'].include?(barcode.to_s.split('-')[-1].to_s)
                        barcode = barcode.split('-')[0..-2].join('-')
                    end

                    if pro_where == "한국" and where3 == "B2B국내"
                        action_1 = 1
                    elsif pro_where != "한국" and where3 == "B2B해외"
                        action_1 = 1
                    else
                        action_1 = 2
                    end

                    if action_1 == 2 or opt_con22 == '0' or pro_type == "상품권" or (opt+' '+opt2).include?('카쿠') or barcode.to_s == '89343202002665'

                    else
                        action_check = 1
						pro_con = (opt_con.to_i * data2[14].to_i).to_s
                        soonje_memory = Array.new
                        
                        soonje_memory << brand_name
                        soonje_memory << pro_name
                        soonje_memory << opt + '/' + opt2
                        soonje_memory << ""
                        soonje_memory << ""
                        soonje_memory << ""

                        soonje_memory << procode
                        soonje_memory << barcode
                        soonje_memory << pro_con

                        if where3 == "B2B해외"
                            soonje_memory << data2[19]
                        end

                        port_number_status = data2[33].to_s 
                        if port_number_status.include?('정상')
                            if port_number_status.include?('주문자')
                                soonje_memory << data2[15].to_s
                                if data2[16].to_s.include?('0000')
                                    soonje_memory << data2[18].to_s
                                else
                                    if data2[16].to_s.include?('010')
                                        soonje_memory << data2[16].to_s
                                    else
                                        soonje_memory << data2[18].to_s
                                    end
                                end
                            else
                                soonje_memory << data2[17].to_s
                                if data2[18].to_s.include?('0000')
                                    soonje_memory <<  data2[16].to_s
                                else
                                    if data2[18].to_s.include?('010')
                                        soonje_memory << data2[18].to_s
                                    else
                                        soonje_memory << data2[16].to_s
                                    end
                                end
                                end
                            else
                            if data2[16].to_s.include?('010')
                                if data2[16].to_s.include?('0000')
                                    soonje_memory << data2[17].to_s
                                    soonje_memory << data2[18].to_s
                                else
                                    soonje_memory << data2[15].to_s
                                    soonje_memory << data2[16].to_s
                                end
                            else
                                soonje_memory << data2[17].to_s #수취인이름
                                soonje_memory << data2[18].to_s #수취인 핸드폰 번호
                            end
                        end


                        soonje_memory << data2[20]
                        soonje_memory << data2[21]
                        soonje_memory << data2[22]

                        soonje_memory << data2[10].to_s
                        soonje_memory << data2[4].to_s
                        soonje_memory << data2[5].to_s
                        soonje_memory << data2[9].to_s
                        soonje_memory << data2[15].to_s
                        soonje_memory << data2[16].to_s

                        soonje_memory.each_with_index do |cc, index33|
                            worksheet.add_cell(index, index33, cc)
                        end

                        index += 1
                    end
                end
            end

	    elsif where3 == '한국' or where3 == '카쿠'
		column_name << '주문번호'
		column_name << '주문일'
		column_name << '수령자명'
		column_name << '수령자 우편번호'
		column_name << '수령자 연락처'
		column_name << '수령자주소'
		column_name << '상품명'
		column_name << '옵션명'
		column_name << '수량'
		column_name << '배송메모'
		column_name << '박스타입'

		index = 0

        sheet1.column(4).width = 50
		sheet1.column(14).width = 50

		column_name.each do |col_name|
			sheet1.row(0).push(col_name)
		end

		data.each_with_index do |i,index2|
		  data2 = Array.new
		  i.split('<td')[1..-1].each do |k|
			data2 << k.split('</td>')[0].split('>')[1]
		  end
          if data2[11].to_s.include?('하동')

          else
            if data2[3].to_s.split(' ').join('') == '' or where2 == '강제다운로드'
                if data2[4].to_s == company_name
                    barcode = data2[12].to_s.split(' ').join('')
                    procode = data2[11].to_s.split(' ').join('')
                    godocode = ''
                    opt = ''
                    opt2 = ''
                    opt_con = 1
                    opt_code = ''
                    pro_name = ''
                    brand_name = ''
                    pro_type = ''
                    pro_where = ''
                    if ['01','02','03','04','05','06'].include?(procode.to_s.split('-')[-1].to_s)
                        procode = procode.split('-')[0..-2].join('-')
                    end
                    result = client.execute("select brandName, godocode, proName, proType, name1 from PRODUCT where procode = '#{procode.to_s}'")
                    result.each do |i|
                        brand_name = i[0].to_s
                        godocode = i[1].to_s
                        pro_name = i[2].to_s
                        pro_type = i[3].to_s
                        pro_where = i[4].to_s
                        break
                    end
                    opt_code22 = '100'
                    if pro_type == '어그'
                        result = client.execute("select optName1,optCode,optCon, curCon, optName2 from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
                        result.each do |i|
                            opt = i[0].to_s
                            opt_code = i[1].to_s
                            opt_code22 = i[3].to_s
                            opt2 = i[4].to_s
                            pro_name = pro_name.split(' ')[0..-1].join(' ') + opt + ' ' + opt2
                            break
                        end
                    else
                        result = client.execute("select optName1, optCode, optCon, curCon, optName2 from CTOPOPTION2 where barcode = '#{barcode.to_s.split('-')[0]}'")
                        result.each do |i|
                            opt_code = i[1].to_s
                            opt = i[0].to_s
                            opt2 = i[4].to_s
                        end
                    end 
                    opt_con = 1
                    if pro_type != '어그'
                        result = client.execute("select optCon, optName1, optName2, curCon from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
                        result.each do |i|
                            opt_con = i[0].to_i
                            opt_code22 = i[3].to_s
                        end
                    end
                    con_value = opt_con.to_i * data2[14].to_i
                    if (pro_where == '한국' and where3 == '한국') or (pro_where == '호주' and (opt.to_s + opt2.to_s).include?('카쿠') and where3 == '한국')
                      if opt_code22.to_s == '0' or pro_type == '상품권' or (opt.to_s + opt2.to_s).include?('카쿠') or barcode.to_s == '89343202002665' or barcode.to_s.include?('카쿠')

                        else
                            action_check = 1
                            sheet1.row(index+1).push(data2[10])
                            sheet1.row(index+1).push(data2[2])
                            sheet1.row(index+1).push(data2[17])
                            sheet1.row(index+1).push(data2[20])
                            sheet1.row(index+1).push(data2[18])
                            sheet1.row(index+1).push(data2[21])
                            sheet1.row(index+1).push(pro_name)
                            sheet1.row(index+1).push(opt)
                            sheet1.row(index+1).push(con_value.to_s)
                            sheet1.row(index+1).push(data2[22])
                            sheet1.row(index+1).push('극소')
                            index += 1
                            time_text = Time.now.to_s.split(' ')[0]

                            client.execute("update CTOPORDER set download1 = '#{time_text}', date3 = '#{time_text}' where _id = #{data2[0].to_s}")
                        end
                    else
                      if (opt.to_s + opt2.to_s).include?('카쿠') or barcode.to_s == '89343202002665' or barcode.to_s.include?('카쿠')
                            action_check = 1
                            sheet1.row(index+1).push(data2[10])
                            sheet1.row(index+1).push(data2[2])
                            sheet1.row(index+1).push(data2[17])
                            sheet1.row(index+1).push(data2[20])
                            sheet1.row(index+1).push(data2[18])
                            sheet1.row(index+1).push(data2[21])
                            sheet1.row(index+1).push(pro_name)
                            sheet1.row(index+1).push(opt)
                            sheet1.row(index+1).push(con_value.to_s)
                            sheet1.row(index+1).push(data2[22])
                            sheet1.row(index+1).push('극소')
                            index += 1
                            time_text = Time.now.to_s.split(' ')[0]

                            client.execute("update CTOPORDER set download1 = '#{time_text}', date3 = '#{time_text}' where _id = #{data2[0].to_s}")
                        end
                    end
                end
            end
		  end
		end
	  end

	  time_dd = Time.now.to_s.split(' ')[0].split('-').join('')
      if where3 == "B2B해외" or where3 == "B2B국내"
        if where3 == "B2B해외"
            naruto_name = "(해외)"
        else
            naruto_name = "(국내)"
        end
        path = './public/excel/'+time_dd+'/'+time_dd+'-'+company_name+' '+naruto_name+'.xlsx'
      else
        path = './public/excel/'+time_dd+'/'+time_dd+'-'+company_name+'.xls'
      end
      if action_check == 1
        if where3 == "B2B해외" or where3 == "B2B국내"
            workbook.write path
        else
            book.write path
        end
      end
	  return path
	end

        def soonje_search_view
          @data = Array.new
          client = ActiveRecord::Base.connection
          code = params["code"].to_s
          result = client.execute("select * from CTOPOPTION2 where barcode = '"+code+"'")
          result.each do |i|
             @data << i
          end

          result = client.execute("select * from CTOPOPTION2 where proId = '"+code+"'")
          result.each do |i|
            @data << i
          end

          if code == "" or code == " "

          else
            result = client.execute("select * from PRODUCT where proDbName like '%"+code+"%'")
            result.each do |i|
              @data << i
            end
          end
        end

	def download_action9
		data = params['data']
		time_dd = Time.now.to_s.split(' ')[0].split('-').join('')
		dir_name = './public/excel/'+time_dd
		if Dir.exist?(dir_name)
            file_list = Dir.entries(dir_name)
            file_list.each do |file|
                if file == '.' or file == '..'

                else
                    File.open(dir_name+'/'+file, 'r') do |f|
                        File.delete(f)
                    end
                end
            end
		  	Dir.delete(dir_name)
		end
        begin
		    Dir.mkdir(dir_name)
        rescue

        end
	  	file_name = Array.new
	  	['CTOP','FC','UM','TP','VM','MDD','MP'].each do |company_name|
		  	file_name << download_action_multi(company_name, data, params['where2'].to_s)
		end
		dir_name2 = dir_name+'.zip'
        begin
            File.open(dir_name2, 'r') do |f|
                File.delete(f)
            end
        rescue

        end
		Zip::File.open(dir_name2, Zip::File::CREATE) do |zipfile|
		  	file_name.each do |file|
                begin
			  	    zipfile.add(File.basename(file), file)
                rescue => e
                    puts '압축도중에러...'
                    puts e
                end
			end
		end

		render :json => {'result' => 'ok' , 'answer' => dir_name2.split('./public')[1]}
    end

    def download_action_multi(company, data, where2)
	    begin
		    ctop_name = {
			    'CTOP' => '씨탑',
			    'FC' => '푸드캘린더',
			    'UM' => '엉뚱한마켓',
			    'TP' => '트랜드피커',
			    'VM' => '비타민멘토',
			    'MDD' => '더담담',
                'MP' => '몬스터프라이스'
		    }

		    soonje_data = {
			    'CTOP' => ['20180002410', '씨탑(CTOP)', '최민준', '010-3560-4739', '10343', '경기도 고양시 일산서구 산현로 15(탄현동,무광프라자) 502호-B05'],
			    'FC' => ['20190003892','푸드캘린더','최민준','010-3189-0815','12913','경기도 하남시 미사강변중앙로 220(망월동, 우성미사타워)7층 701호-C298'],
			    'UM' => ['20200004390','엉뚱한마켓','김잔디','010-4714-0530','4794','서울특별시 성동구 아차산로 113 (성수동2가) 8층 889호'],
			    'TP' => ['20230005269','트렌드피커','최민준','010-2613-1454','2262','서울특별시 중랑구 신내역로 165(신내동, 신내 데시앙포레) 221동 902호'],
			    'VM' => ['20230005264','비타민멘토','최민준','010-2275-6190','02055','서울특별시 중랑구 신내역로 165(신내동, 신내우디안아파트) 221동 902호'],
			    'MDD' => ['20230002905','더담담','김잔디','010-6890-0221','4794','서울특별시 성동구 아차산로 113(성수동2가, 삼진빌딩) 1동 8층 8243호'],
                'MP' => ['2024001000180364','몬스터 프라이스(MONSTER PRICE)','최민준','010-4835-6190','21378','인천광역시 부평구 원적로472번길 2, 4층 401호']
		    }

		    client = ActiveRecord::Base.connection
		    workbook = RubyXL::Workbook.new
		    worksheet = workbook[0]
		    worksheet.add_cell(3, 0,"전송구분\n9:원본")
		    worksheet.add_cell(3, 1,"신고제품구분\n1:식품\n2:식품첨가물\n3:기구 또는 용기포장\n5:축산물")
		    worksheet.add_cell(3, 2,"신고구분\nA:본신고\nB:사전신고")
		    worksheet.add_cell(3, 3,'신고기관코드명')
		    worksheet.add_cell(3, 4,'선(기)명(50)')
		    worksheet.add_cell(3, 5,'B/L(20)')
		    worksheet.add_cell(3, 6,'보관창고코드(8)')
		    worksheet.add_cell(3, 7,'보관창고명(100)')
		    worksheet.add_cell(3, 8,'창고전화번호(14)')
		    worksheet.add_cell(3, 9,'입항일자(8)')
		    worksheet.add_cell(3, 10,'반입일자(8)')
		    worksheet.add_cell(3, 11,'성명(50)')
		    worksheet.add_cell(3, 12,'연락처(14)')
		    worksheet.add_cell(3, 13,'개인통관고유부호(13)')
		    worksheet.add_cell(3, 14,'영업등록번호(11)')
		    worksheet.add_cell(3, 15,'상호(100)')
		    worksheet.add_cell(3, 16,'성명(50)')
		    worksheet.add_cell(3, 17,'연락처(14)')
		    worksheet.add_cell(3, 18,'우편번호(5)')
		    worksheet.add_cell(3, 19,'주소(150)')
		    worksheet.add_cell(3, 20,'전자상거래사이트주소(200)')
		    worksheet.add_cell(3, 21, '전자상거래사이트주소(200)')
		    worksheet.add_cell(3, 22, '제품명(200)')
		    worksheet.add_cell(3, 23, '제품 URL(200)')
		    worksheet.add_cell(3, 24, '제조회사명(100)')
		    worksheet.add_cell(3, 25, "제조국가\n코드(2)")
		    worksheet.add_cell(3, 26, "제조국가\n명(50)")
		    worksheet.add_cell(3, 27, '총수량')
		    worksheet.change_row_height(3, 150)
            action_check = 0
		    index = 4
		    data.each_with_index do |i,index2|
			    data2 = Array.new
			    i.split('<td')[1..-1].each do |k|
				    data2 << k.split('</td>')[0].split('>')[1]
			    end
			    if data2[35].to_s.split(' ').join('') == '' or where2 == '강제다운로드'
				    if data2[4].to_s == company
					    barcode = data2[12].split(' ').join('')
					    url = ''
					    pro_name = ''
					    en_name = ''
					    name1 = ''
					    name2 = ''
					    name3 = ''
					    opt_con = 1
					    result = client.execute("select url, optCon from CTOPOPTION2 where barcode = '#{barcode.to_s}'")
					    result.each do |i|
						    opt_con = i[1]
					    end
					    pro_id = data2[11].to_s
					    if barcode.to_s.include?('-')
						    pro_id = pro_id.split('-')[0..-2].join('-')
					    end
					    result = client.execute("select url, optCon from CTOPOPTION2 where proId = '#{pro_id}'")
					    result.each do |i|
						    url = i[0].to_s
						    if url.to_s != ''
							    break
						    end
					    end
					    pro_type = '어그'
                        procode2 = data2[11].to_s
                        if data2[11].to_s == 'NT-LUNG'
                            procode2 = 'RT-'+data2[11].to_s
                        end
					    result = client.execute("select enName, name1, name2, enbrandName, proType from PRODUCT where procode = '#{procode2}'")
					    result.each do |i|
						    en_name = i[0]
						    name1 = i[1]
						    name2 = i[2]
						    name3 = i[3]
						    pro_type = i[4]
					    end
					    if name2 == 'KR' or name2 == 'CN' or pro_type == '상품권' or data2[7].to_s.split(' ').join('') == '' or pro_type != '건기식'

					    else
                            action_check = 1
						    worksheet.add_cell(index, 0, "9")
						    worksheet.add_cell(index, 1, "1")
						    worksheet.add_cell(index, 2, "B")
						    worksheet.add_cell(index, 3, '인천국제공항수입식품검사소')
						    worksheet.add_cell(index, 4, '사전신고')
						    worksheet.add_cell(index, 5, data2[7].to_s) #송장번호
						    worksheet.add_cell(index, 6, '00000000')
						    worksheet.add_cell(index, 7, '')
						    worksheet.add_cell(index, 8, '')
						    worksheet.add_cell(index, 9, '99991231')
						    worksheet.add_cell(index, 10, '99991231')
						    if data2[33].to_s.include?('주문자')
							    master_name = data2[15]
							    master_phone = data2[16]
						    else
							    master_name = data2[17]
							    master_phone = data2[18]
						    end
						    if data2[19].to_s == '미입력' or data2[19].to_s.split(' ').join('') == ''
							    master_port = ''
						    else
							    master_port = data2[19].to_s
						    end
						    worksheet.add_cell(index, 11, master_name) #이름
						    worksheet.add_cell(index, 12, master_phone) #연락처
						    worksheet.add_cell(index, 13, master_port) #개인통관부호
						    worksheet.add_cell(index, 14, soonje_data[company][0]) #영업등록번호 (업체별로다름)
						    worksheet.add_cell(index, 15, soonje_data[company][1]) #상호명
						    worksheet.add_cell(index, 16, soonje_data[company][2]) #업체별 대표자이름
						    worksheet.add_cell(index, 17, soonje_data[company][3]) #업체별 연락처
						    worksheet.add_cell(index, 18, soonje_data[company][4]) #업체별 우편번호
						    worksheet.add_cell(index, 19, soonje_data[company][5]) #업체별 주소
						    worksheet.add_cell(index, 20, url) #상품주소
						    worksheet.add_cell(index, 21, url) #상품주소
						    worksheet.add_cell(index, 22, en_name) #영어제품명
						    worksheet.add_cell(index, 23, url) #상품주소
						    worksheet.add_cell(index, 24, name3) #제조회사명
						    worksheet.add_cell(index, 25, name2) #제조국가코드(2)
						    worksheet.add_cell(index, 26, name1) #제조국가명
						    worksheet.add_cell(index, 27, (data2[14].to_i*opt_con.to_i).to_s) #총수량

						    index += 1
						    time_text = Time.now.to_s.split(' ')[0]
						    client.execute("update CTOPORDER set download2 = '#{time_text}' where _id = #{data2[0].to_s}")
					    end
				    end
			    end
			end
			time_dd = Time.now.to_s.split(' ')[0].split('-').join('')
		    path = './public/excel/'+time_dd+'/'+time_dd+'-'+company+'.xlsx'
            if action_check == 1
		        workbook.write path
            else
                
            end
			return path
	    rescue => e
		    puts 'error ==> ' + e.to_s
			return ''
	    end
    end

    def edit_action
        begin
            client = ActiveRecord::Base.connection
            row = params['data']
            data2 = Array.new
            row.each do |i|
                begin
                  data2 = Array.new
                    db_id = i.split('<td>')[1].split('</td>')[0]
                    i.split('<td')[1..-1].each do |k|
                        data2 << k.split('</td>')[0].split('>')[1]
                    end

                    m = Hash.new
                    m['date1'] = data2[1]
                    m['date2'] = data2[2]
                    m['date3'] = data2[3]
                    m['name1'] = data2[4]
                    m['market1'] = data2[5]
                    m['date4'] = data2[6]
                    m['deliNo'] = data2[7]
                    m['code1'] = data2[8]
                    m['unicode'] = data2[9]
                    m['code2'] = data2[10]
                    m['procode'] = data2[11]
                    m['barcode'] = data2[12]
                    m['con1'] = data2[13]
                    m['optcon'] = data2[14]
                    m['ordName'] = data2[15]
                    m['ordTel'] = data2[16]
                    m['getName'] = data2[17]
                    m['getTel'] = data2[18]
                    m['pnum'] = data2[19]
                    m['enum'] = data2[20]
                    m['home'] = data2[21]
                    m['messege'] = data2[22]
                    m['che1'] = data2[23]
                    m['moneyNum'] = data2[24]
                    m['money1'] = data2[25]
                    m['money2'] = data2[26]
                    m['money3'] = data2[27]
                    m['money4'] = data2[28]
                    m['moneyDate'] = data2[29]
                    m['money5'] = data2[30]
                    m['money6'] = data2[31]
                    m['productName'] = data2[32]
                    m['api_result'] = data2[33]
                    m['download1'] = data2[34]
                    m['download2'] = data2[35]
                    m['bin1'] = data2[36]
                    m['bin2'] = data2[37]
                    m['bin3'] = data2[38]
                    m2 = Array.new
                    m.each do |key,value|
                        m2 << key + ' = "' + value.to_s.split('"').join('') + '"'
                    end

                    q = "update CTOPORDER set #{m2.join(',')} where _id = " + db_id.to_s
                    client.execute(q)
                rescue => e
                    puts e
                end
            end
            render :json => {'result' => 'ok'}
        rescue
            render :json => {'result' => 'no'}
        end
    end



    def delete_action
        client = ActiveRecord::Base.connection
        row = params['data']
        row.each do |i|
            begin
                db_id = i.split('<td>')[1].split('</td>')[0]
                q = 'delete from CTOPORDER where _id = '+db_id.to_s
                client.execute(q)
            rescue => e
                puts e
            end
        end
        render :json => {}
    end

    def search_number(text)
        answer = false
        begin
          for n in 0..9
            if text.to_s.include?(n.to_s)
              answer = true
              break
            end
          end
        rescue

        end
        return answer
    end

    def search_korea_size(text)
        answer = false
        for n in 200..350
            if text.include?(n.to_s)
            answer = true
            break
            end
        end
        return answer
    end

    def coupon
        if params['code'].to_s.include?('+')
            answer = Array.new
            code = params['code'].split(' ').join('')
            code.split('+').each do |i|
                answer << i
            end
        else
            answer = [params['code'].to_s]
        end
        render :json => {'result' => 'no', 'code' => answer}
    end

    def barcode_search
        answer = Array.new
        client = ActiveRecord::Base.connection
        code_value = params['code'].to_s
        if code_value == ''

        else
            if code_value == 'NT-LUNG'
                code_value = 'RT-NT-LUNG'
            end
            result2 = client.execute("SELECT * FROM CTOPOPTION2 where proId = '#{code_value}'")
            result2.each do |db_data|
                answer << "<option value='"+db_data[2].to_s+"'>"+db_data[2].to_s + '  ' + db_data[4].to_s + '  ' + db_data[5].to_s+"</option>"
            end
        end
        render :json => {'result' => answer}
    end

    def optionEditAction
        id = params["id"].to_s
        proid = params["proId"].to_s
        barcode = params['barcode'].to_s
        option1 = params['option1'].to_s
        option2 = params['option2'].to_s
        price1 = params['price1'].to_s
        price2 = params['price2'].to_s
        curCon = params['curCon'].to_s
        client = ActiveRecord::Base.connection
        if barcode == "" or proid == "" or id == ""

        else
            query = "update CTOPOPTION2 set proId = '#{proid}', barcode = '#{barcode}', optName1 = '#{option1}', optName2 = '#{option2}', price = '#{price1}', priceDel = '#{price2}', curCon = '#{curCon}' where _id = #{id}"
            client.execute(query)
        end

        render :json => {'result' => "ok"}
    end

    def optionStatus
        @data = Array.new
        client = ActiveRecord::Base.connection
        search_type = params['type'].to_s
        search_value = params['search'].to_s
        page1 = params['page'].to_s
        pagesize = params['size'].to_s

        if page1 == ''
            page1 = '0'
        end

        if pagesize == ''
            pagesize = '300'
        end

        if search_type == ''
            search_type = 'barcode'
        end

        result = client.execute("select * from CTOPOPTION2 where #{search_type} like \"#{search_value}%\" limit #{page1}, #{pagesize}")
        result.each do |i|
            @data << i
        end
    end

    def orderStatus
        @data = Array.new
        client = ActiveRecord::Base.connection
        @time = params['date'].to_s
        @date_option = params['date_option'].to_s
        if @date_option == ''
            @date_option = '작성일'
        end
        @date_option_name_dict = Hash.new
        @date_option_name_dict['작성일'] = 'date1'
        @date_option_name_dict['주문일'] = 'date2'
        @date_option_name_dict['발주일'] = 'date3'
        @date_option_name_dict['출고일'] = 'date4'


        @select_default = Hash.new
        @select_default[@date_option] = 'selected'
        @select2 = ['소매주문번호', '수취인명', '주문자명', '핸드폰번호', '송장번호', '바코드']
        @select2_name_dict = Hash.new
        @select2_name_dict['소매주문번호'] = 'code2'
        @select2_name_dict['수취인명'] = 'getName'
        @select2_name_dict['주문자명'] = 'ordName'
        @select2_name_dict['핸드폰번호'] = 'ordTel'
        @select2_name_dict['송장번호'] = 'deliNo'
        @select2_name_dict['바코드'] = 'barcode'

        @date_option2 = params['option2'].to_s
        if @date_option2 == ''
            @date_option2 = '소매주문번호'
        end

        @select_default2 = Hash.new
        @select_default2[@date_option2] = 'selected'
        if @time == ''
            @time = Time.now.to_s.split(' ')[0]
        end

        @time2 = params['date2'].to_s
        if @time2 == ''
            @time2 = Time.now.to_s.split(' ')[0]
        end
        # @time = '2024-02-28'
        # @time2 = '2024-02-28'
        @search_text = params['search_text'].to_s
        @data = client.execute("select DISTINCT c._id, c.date1, c.date2, c.date3, c.name1, c.market1, c.date4, CASE WHEN i.curCon IS NULL OR i.curCon = '0' THEN '품절' ELSE c.deliNo END AS deliNo, c.code1, c.unicode, c.code2, c.procode, c.barcode, c.con1, c.optcon, c.ordName, c.ordTel, c.getName, c.getTel, c.pnum, c.enum, c.home, c.messege, c.che1, c.moneyNum, c.money1, c.money2, c.money3, c.money4, c.moneyDate, c.money5, c.money6, c.productName, c.api_result, c.download1, c.download2, c.bin1, c.bin2, c.bin3 from CTOPORDER c LEFT JOIN CTOPOPTION2 i ON c.barcode = i.barcode where c.#{@date_option_name_dict[@date_option]} >= '#{@time}' and c.#{@date_option_name_dict[@date_option]} <= '#{@time2}' and c.#{@select2_name_dict[@date_option2]} like '%#{@search_text}%' ORDER BY _id ASC")
        # result.each do |i|
        #     barcode = i[12].to_s
        #     cc = i
        #     result2 = client.execute('select curCon from CTOPOPTION2 where barcode = "'+barcode.to_s+'"')
        #     result2.each do |kk|
        #         if kk[0].to_s == '0'
        #             cc[6] = cc[6].to_s + '품절'
        #             break
        #         end
        #     end
        #     # if cc[33].to_s.include?('휴대폰')
        #     #     cc[33]
        #     # end
        #     @data << cc
        # end
    end

    def product_add

    end

    def soonje_test
        client = ActiveRecord::Base.connection
        result = client.execute('select * from CTOPORDER limit 3')
        result.each do |i|
            p i
        end
    end

    def product_add_action
        client = ActiveRecord::Base.connection
        product = params['product']
        options = params['options']

        product = product.map do |i|
            "'"+i.to_s.split('"').join('').split("'").join('')+"'"
        end

        q = "insert into PRODUCT(supType, comName, name1, name2, selName, proType, enbrandName, enName, brandName, procode, proName, counter, godocode, tel) values("+product.join(',')+")"
        client.execute(q) 
        options.each do |key, v|
            op = v.map do |k|
                "'"+k.to_s.split('"').join('').split("'").join('')+"'"
            end
            q2 = "insert into CTOPOPTION2(proId, barcode, conCheck, optName1, optName2, optCon, optCode, price, priceDel, url, curCon) values("+op.join(',')+")"
            client.execute(q2)
        end

        render :json => {'result' => 'ok'}
    end

    def money_api(num, name, tel)
        tel = tel.to_s.split('-').join('')
        req = HTTP.get('https://unipass.customs.go.kr:38010/ext/rest/persEcmQry/retrievePersEcm?crkyCn=w240t254w013x074c030o090l0&persEcm='+num.to_s+'&pltxNm='+name.to_s+'&cralTelno='+tel.to_s)
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
                return "3"
            end
        end
    end

    def songjang_upload
      client = ActiveRecord::Base.connection
      data = params['data']
      data.each do |i|
        data2 = i[1]
        if data2['비고2'].to_s == ''
            if data2['소매주문번호'].to_s == ''
                some_number = data2['주문번호'].to_s.split(' ').join('')
            else
                some_number = data2['소매주문번호'].to_s.split(' ').join('')
            end
        else
            some_number = data2['소매주문번호'].to_s.split(' ').join('')
        end
        if data2['비고2'].to_s == ''
            if data2['소매주문번호'].to_s == ''
                result = client.execute('select _id, procode from CTOPORDER where code2 = "'+some_number+'" and unicode = "'+data2['품목번호 / 비젬번호'].to_s.split(' ').join('')+'"')
            else
                result = client.execute('select _id, procode from CTOPORDER where code2 = "'+some_number+'"')
            end
        else
            result = client.execute('select _id, procode from CTOPORDER where code2 = "'+some_number+'"')
        end
        result.each do |order_db_data|
          order_id = order_db_data[0].to_s
          procode  = order_db_data[1].to_s
          pro_name = ''
          result2 = client.execute('select proName from PRODUCT where procode = "'+procode+'"')
          result2.each do |i2|
	            pro_name = i2[0].to_s
          end
          if pro_name.include?('상품권')

          else
            if data2['비고2'].to_s == ''
                if data2['소매주문번호'].to_s == ''
                  client.execute("update CTOPORDER set deliNo = '#{data2['운송장번호'].to_s}', date4 = '#{Time.now.to_s.split(' ')[0]}' where _id = #{order_id.to_s}")
                else
                  client.execute("update CTOPORDER set deliNo = '#{data2['송장번호'].to_s}', code1 = '#{data2['도매주문번호'].to_s}', date4 = '#{Time.now.to_s.split(' ')[0]}' where _id = #{order_id.to_s}")
                end
            else
                client.execute("update CTOPORDER set bin2 = '#{data2['비고2'].to_s}' where _id = #{order_id.to_s}")
            end
          end
        end
      end

      render :json => {'result' => 'ok'}
    end


    def moonja_download
	    begin
            client = ActiveRecord::Base.connection
		    column_name = Array.new
            column_name << '소매주문번호'
		    column_name << '주문자명'
		    column_name << '주문자휴대폰번호'
		    column_name << '수신자명'
		    column_name << '수신자휴대폰번호'
		    column_name << '발신휴대폰업체'
		    column_name << '문자내용'

		    data = params['data']
		    book = Spreadsheet::Workbook.new
		    sheet1 = book.create_worksheet
		    index = 0

            sheet1.column(0).width = 50
		    sheet1.column(1).width = 50
		    sheet1.column(3).width = 50
		    sheet1.column(5).width = 150

		    column_name.each do |col_name|
			    sheet1.row(0).push(col_name)
		    end

		    moonja_text = Hash.new
		    moonja_text['CNC'] = "안녕하십니까, 고객님.\n주문정보에 기입된 통관고유부호를 조회해 보니 오류로 확인되어 안내해 드립니다.\n수취인 명의의 통관고유부호와 전화번호를  재확인 후 회신주시면 처리 진행해 드리겠습니다.\n감사합니다."
		    moonja_text['CTOP-FC-TP-VM'] = "안녕하세요, 고객님\n통관번호가 수취인과 일치하지 않아 연락드렸습니다.\n확인 후 회신으로 통관번호와 수취인명의 전화번호, 수취인명을 남겨주시면 감사하겠습니다.\n감사합니다. :)"
		    moonja_text['UM-MDD'] = "고객님~안녕하세요!\n통관번호 오류로 확인되어 안내드립니다.\n통관번호와 고객님 성함 및 전화번호가 일치하지 않아, 확인 후 답변 부탁드립니다.\n감사합니다. ^^"
		    data.each_with_index do |i,index2|
                data2 = Array.new
                i.split('<td')[1..-1].each do |k|
                        data2 << k.split('</td>')[0].to_s.split('>')[1].to_s
                end
                if data2[33].to_s == '개통부오류'
                    result = client.execute('select name1 from PRODUCT where procode = "'+data2[11].to_s+'"')
                    country_check = ''
                    result.each do |db_data|
                        country_check = db_data[0]
                    end
                    kaku_check = ''
                    result = client.execute('select optName1, optName2 from CTOPOPTION2 where barcode = "'+data2[12].to_s+'"')
                    result.each do |db_data|
                        kaku_check = db_data[0].to_s + ' ' + db_data[1].to_s
                    end
                    if country_check == '한국' or country_check == '중국' or kaku_check.include?('카쿠') or data2[12].to_s == '89343202002665'

                    else
                        compuny = data2[4]
                        sheet1.row(index+1).push(data2[10])
                        sheet1.row(index+1).push(data2[15]) #주문자명
                        sheet1.row(index+1).push(data2[16]) #주문자휴대폰번호
                        sheet1.row(index+1).push(data2[17]) #주문자휴대폰번호
                        sheet1.row(index+1).push(data2[18]) #주문자휴대폰번호
                        sheet1.row(index+1).push(compuny) #업체명
                        moonja_value = ''
                        moonja_text.each do |key,vv|
                            if key.include?(compuny)
                                moonja_value = vv
                            end
                        end
                        sheet1.row(index+1).push(moonja_value) #문자내용
                        index += 1
                    end
                end
		    end
		    path = './public/excel/'+Time.now.to_i.to_s+'-'+session[:id].to_s+'-문자발송내용.xls'
		    book.write path

		    render :json => {'result' => 'ok' , 'answer' => path.split('./public')[1]}
	    rescue => e
		    puts 'error ==> ' + e.to_s
		    render :json => {'result' => 'no'}
	    end
    end

    def csBoard
		@order_name = params['order_number'].to_s
		@data = Array.new
		@content = Array.new
		client = ActiveRecord::Base.connection
		result = client.execute('select code2, date2, ordName, ordTel, getName, getTel, pnum, api_result, productName, optCon, money1, home, deliNo, date4, bin2 from CTOPORDER where code2 = "'+@order_name.to_s+'"')
		result.each do |value|
			@data = value
			break
		end

		result = client.execute('select * from CTOPCS2 where code2 = "'+@order_name+'"')
		result.each do |value|
		    @content << value
		end
                @content = @content.reverse
    end

    def csContentUpload
		content = params['content'].to_s
		client = ActiveRecord::Base.connection
		result = client.execute("insert into CTOPCS2(code2, content, name, time) values('#{params['id'].to_s}','#{content}','#{session[:name].to_s}','#{Time.now.to_s.split(' ')[0]}')")
		render :json => {}
    end

    def apisetting
        client = ActiveRecord::Base.connection
        @data = Array.new
        result = client.execute('select * from MARKETAPI')
        result.each do |i|
            @data << i
        end
    end

    def api_update
        client = ActiveRecord::Base.connection
        market_name = params['market'].to_s
        user_name = session[:name].to_s
        market_id = params['market_id'].to_s
        market_pw = params['market_pw'].to_s
        access_key = params['access_key'].to_s
        secret_key = params['secret_key'].to_s
        memory = [market_name, user_name, market_id, market_pw, access_key, secret_key, '활성']
        memory2 = memory.map { |i|
            '"'+i.to_s+'"'
        }
        query = 'insert into MARKETAPI(market, username, market_id, market_pw, access_key, secret_key, status) values('+memory2.join(',')+')'
        client.execute(query)

        render :json => {}
    end

    def api_edit
        client = ActiveRecord::Base.connection
        id_list = params['data']
        id_list.each do |i|
            id_value = i[1][0].to_s
            edit_data = i[1][1..-1]
            index = 0
            query_values = Array.new
            column_names = ['market', 'username', 'market_id', 'market_pw', 'access_key', 'secret_key', 'status']
            edit_data.each_with_index do |k,index|
                v = column_names[index] + ' = "'+k.to_s+'"'
                query_values << v
            end

            query_val = 'update MARKETAPI set '+query_values.join(',')+' where _id = '+id_value
            client.execute(query_val)
        end

        render :json => {}
    end

    def api_delete
        client = ActiveRecord::Base.connection
        id_list = params['data']
        id_list.each do |id|
            q = 'delete from MARKETAPI where _id = '+id.to_s
            client.execute(q)
        end

        render :json => {}
    end
end



