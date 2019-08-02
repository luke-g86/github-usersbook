//
//  Protocols.swift
//  github-usersbook
//
//  Created by Lukasz on 28/07/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation

// Dependency injection of the coreData stack

protocol DataControllerClient {
    func setDataController(stack: DataController)
}

protocol UserSelectionDelegate: class {
    func userSelected(_ newUser: User)
}
