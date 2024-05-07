require 'http'
require "crack"
require 'json'

req = HTTP.get('https://unipass.customs.go.kr:38010/ext/rest/persEcmQry/retrievePersEcm?crkyCn=w240t254w013x074c030o090l0&persEcm=P190022480590&pltxNm=고미란&cralTelno=01067508529')
myXML  = Crack::XML.parse(req.to_s)
myJSON = myXML.to_json
myJSON = JSON.parse(myJSON)
result = myJSON['persEcmQryRtnVo']
puts result