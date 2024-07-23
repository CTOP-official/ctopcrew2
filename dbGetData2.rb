require 'mysql2'
require 'csv'

con = Mysql2::Client.new(:host => "localhost", :username => "ctop", :password => "0815", :database => "ctop")
c = CSV.open("./ctopcrewProduct2.csv", "w")

result = con.query("select * from PRODUCT")

result.each_with_index do |i,index|
  if index == 0
    c << i.keys
  end
  c << i.values
end

c2 = CSV.open("./ctopcrewOption2.csv", "w")
result2 = con.query("select * from CTOPOPTION2")

result2.each_with_index do |i,index|
  if index == 0
    c2 << i.keys
  end
  c2 << i.values
end


