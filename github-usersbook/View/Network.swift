//
//  Network.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 09/08/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import Network

class NetworkCheck {
    
    
    func monitor() {
       
        
          let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                return
            }
        }
        
    }
  
    

}
