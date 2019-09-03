//
//  HTTPURLResponse.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 03/09/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    var connectionSuccessful: Bool {
        return 200...299 ~= statusCode
    }
}
