require 'http'

class Coupang
    def initialize(access_key, secret_key)
        @access_key = access_key
        @secret_key = secret_key
        @url = 'https://api-gateway.coupang.com'
    end

    def auth_get(method, path, query)
        time = Time.now.to_s
        #datetime = time.split(' ')[0].split('-').join('')[2..-1]+'T'+time.split(' ')[1].split(':').join('')+'Z'
        datetime= Time.now.getutc.strftime('%y%m%d')+'T'+Time.now.getutc.strftime('%H%M%S')+'Z'
        puts datetime
        message = datetime+method+path+query
        signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @secret_key.encode('utf-8'), message.encode('utf-8'))
        authorization  = "CEA algorithm=HmacSHA256, access-key="+@access_key+", signed-date="+datetime+", signature="+signature
        return authorization
    end

    def order_get(vendor_id, create_at_from, create_at_to)
        path = '/v2/providers/openapi/apis/api/v4/vendors/'+vendor_id+'/ordersheets'
        params = 'createdAtFrom='+create_at_from+'&createdAtTo='+create_at_to+'&status=ACCEPT'
        auth_value = auth_get('GET', path, params)
        http = HTTP.headers('Authorization' => auth_value, 'X-Reqeusted-By' => vendor_id).get(@url+path+'?'+params)
        return http.to_s
    end
end

coupang = Coupang.new('dd9e7a4c-0092-4de4-b970-1122f0381d5e', '71bdf19ade42a59b6bc66aa83432dde282d9ebb2')
puts coupang.order_get('A00914104', '2024-04-04', '2024-04-06')