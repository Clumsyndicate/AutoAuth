//
//  AutoAuth.swift
//  NewAuto
//
//  Created by Johnson Zhou on 25/11/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Foundation
import Alamofire


class AutoAuth {
    
    let url = "https://auth.ykpaoschool.cn/portalAuthAction.do"
    
    var params = ["auth_type": "PAP", "getpasstype": "0", "smsid": "0", "isRadiusProxy": "false", "logintype": "0", "listgetpass": "0", "listpasscode": "0", "viewlogin": "1", "templatetype": "1", "version": "0", "portalpageid": "1", "randstr": "8437", "isHaveNotice": "0", "tname": "2", "checkterminal": "true", "listwxauth": "0", "vlan": "185", "authkey": "ykpao", "mac": "f0:18:98:5e:ba:a7", "wlanacIp": "192.168.186.2", "usertime": "0", "listfreeauth": "0", "twocode": "0", "wlanacname": "hh1u6p", "weizhi": "0", "times": "12", "usertype": "0", "wlanuserip": "192.168.1.71", "is189": "false"]
    
    let headers = [
        "POST": "/portalAuthAction.do HTTP/1.1",
        "Host": "auth.ykpaoschool.cn",
        "Connection": "keep-alive",
        "Content-Length": "645",
        "Cache-Control": "max-age=0",
        "Origin": "https://auth.ykpaoschool.cn",
        "Upgrade-Insecure-Requests": "1",
        "Content-Type": "application/x-www-form-urlencoded",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
        "Referer": "https://auth.ykpaoschool.cn/portal.do?wlanuserip=10.2.188.12&wlanacname=hh1u6p&mac=f0:18:98:5e:ba:a7&vlan=185&url=http://iciba.com/&radnum=530848&rand=5a01a279",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7",
        "Cookie": "_ga=GA1.2.710262873.1479180774; JSESSIONID=6317AD9C18A46D6ECB69F451B499C65E"
    ]
    
    func connect(username: String, password: String) {
        // MAC Address
        if let intfIterator = FindEthernetInterfaces() {
            if let macAddress = GetMACAddress(intfIterator) {
                let macAddressAsString = macAddress.map( { String(format:"%02x", $0) } )
                    .joined(separator: ":")
                print(macAddressAsString)
            }
            
            IOObjectRelease(intfIterator)
        }
        
        
        params["useridtemp"] = username
        params["userid"] = username
        params["passwd"] = password
        Alamofire.request(url, method: HTTPMethod.post, parameters: params, encoding: URLEncoding.default, headers: headers).responseString { (reponse) in
            print(reponse.result.value != nil ? reponse.result.value! : "")
        }
    
    }
    
    func FindEthernetInterfaces() -> io_iterator_t? {
        
        let matchingDict = IOServiceMatching("IOEthernetInterface") as NSMutableDictionary
        matchingDict["IOPropertyMatch"] = [ "IOPrimaryInterface" : true]
        
        var matchingServices : io_iterator_t = 0
        if IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &matchingServices) != KERN_SUCCESS {
            return nil
        }
        
        return matchingServices
    }
    
    func GetMACAddress(_ intfIterator : io_iterator_t) -> [UInt8]? {
        
        var macAddress : [UInt8]?
        
        var intfService = IOIteratorNext(intfIterator)
        while intfService != 0 {
            
            var controllerService : io_object_t = 0
            if IORegistryEntryGetParentEntry(intfService, "IOService", &controllerService) == KERN_SUCCESS {
                
                let dataUM = IORegistryEntryCreateCFProperty(controllerService, "IOMACAddress" as CFString, kCFAllocatorDefault, 0)
                if let data = dataUM?.takeRetainedValue() as? NSData {
                    macAddress = [0, 0, 0, 0, 0, 0]
                    data.getBytes(&macAddress!, length: macAddress!.count)
                }
                IOObjectRelease(controllerService)
            }
            
            IOObjectRelease(intfService)
            intfService = IOIteratorNext(intfIterator)
        }
        
        return macAddress
    }
    
    
}
