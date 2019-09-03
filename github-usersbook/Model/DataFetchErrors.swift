//
//  DataFetchErrors.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 03/09/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation


enum DataFetchErrors: Error {
    
    case network
    case decoding
    
    var details: String {
        switch self {
        case .network:
            return "Fetching data failed"
        case .decoding:
            return "Decoding data failed"
    
        }
    }
}
