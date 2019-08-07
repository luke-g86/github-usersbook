//
//  Protocols.swift
//  github-usersbook
//
//  Created by Lukasz Gajewski on 07/08/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation

Protocol UserSelectionDelegate: class {
    func userSelected(_ newUser: User)
    
}
