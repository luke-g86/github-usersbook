//
//  Network.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 09/08/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import Network
import SystemConfiguration

public class Reachability {
    
    class func isConnectedWithInternet() -> Bool {
        
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let reachability = withUnsafePointer(to: &zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else { return false }
        
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(reachability, &flags) else { return false }
        
        return flags.contains(.reachable) && !flags.contains(.connectionRequired)
    }
    
}
