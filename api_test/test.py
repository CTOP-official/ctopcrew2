import time

datetime = time.strftime('%y%m%d') + 'T' + time.strftime('%H%M%S') + 'Z'
print(datetime)

dateGMT = time.strftime('%y%m%d', time.gmtime())
timeGMT = time.strftime('%H%M%S', time.gmtime())
datetime = dateGMT + 'T' + timeGMT + 'Z'
print(datetime)