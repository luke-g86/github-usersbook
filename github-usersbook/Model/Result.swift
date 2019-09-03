//
//  Result.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 03/09/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation

enum Result<T, U: Error> {
    case success(T)
    case failure(U)
}
