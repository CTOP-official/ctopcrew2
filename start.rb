require 'thread'

thread = Thread.new do 
  system('rails s -b "ssl://0.0.0.0:443?key=./privkey.pem&cert=fullchain.pem"')
end
puts 'start rails...'
thread.run

sleep 5
