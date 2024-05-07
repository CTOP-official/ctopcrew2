f = File.open('./log/development.log','r')
data = f.read()
f.close()
ip_list = Hash.new
data.split('Started GET').each do |t|
	if t.include?('No route')
		ip_text = t.split('for')[1].to_s.split('at')[0]
		ip_list[ip_text] = ""
	end
end

f2 = File.open('./log_get4.txt', 'w')
ipss = ip_list.keys
# data.split('Started GET').each do |t|
# 	if t.include?('192.168.0.1') or t.include?('192.168.0.51')
# 	else
# 		ip_text = t.split('for')[1].to_s.split('at')[0]
# 		if ipss.include?(ip_text)
# 			f2.write(t)
# 			f2.write("\n\n")
# 		end
# 	end
# end
ipss.each do |i|
  f2.write(i)
  f2.write("\n")
end

f2.close()
