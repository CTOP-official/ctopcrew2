import os
import time
import hmac, hashlib
import urllib.parse
import urllib.request
import ssl
import json

from datetime import datetime, timedelta

gmt_time = datetime.now() - timedelta(hours=9)   #한국 기준
gmt_time_str = "{:%y%m%d}T{:%H%M%S}Z".format(gmt_time, gmt_time)
dateGMT = time.strftime('%y%m%d', time.gmtime())
timeGMT = time.strftime('%H%M%S', time.gmtime())
gmt_time_str = dateGMT + 'T' + timeGMT + 'Z'
method = "GET"

path = "/v2/providers/openapi/apis/api/v4/vendors/A00914104/ordersheets"
query = urllib.parse.urlencode({"createdAtFrom": "2024-04-06", "createdAtTo": "2024-04-06", "status": "ACCEPT"})
print(query)
message = gmt_time_str+method+path+query

#replace with your own accesskey
accesskey = "dd9e7a4c-0092-4de4-b970-1122f0381d5e"
#replace with your own secretKey
secretkey = "71bdf19ade42a59b6bc66aa83432dde282d9ebb2"

#********************************************************#
#authorize, demonstrate how to generate hmac signature here
signature=hmac.new(secretkey.encode('utf-8'),message.encode('utf-8'),hashlib.sha256).hexdigest()
authorization  = "CEA algorithm=HmacSHA256, access-key="+accesskey+", signed-date="+gmt_time_str+", signature="+signature
# print out the hmac key
print(authorization)
#********************************************************#

# ************* SEND THE REQUEST *************
url = "https://api-gateway.coupang.com"+path+"?%s" % query

req = urllib.request.Request(url)

req.add_header("Content-type","application/json;charset=UTF-8")
req.add_header("Authorization",authorization)

req.get_method = lambda: method

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

try:
    resp = urllib.request.urlopen(req,context=ctx)
except urllib.request.HTTPError as e:
    print(e.code)
    print(e.reason)
    print(e.fp.read())
except urllib.request.URLError as e:
    print(e.errno)
    print(e.reason)
    print(e.fp.read())
else:
    # 200
    body = resp.read().decode(resp.headers.get_content_charset())
    print(body)

