//
//  User+Extention.swift
//  github-usersbook
//
//  Created by Łukasz Gajewski on 2/8/19.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import CoreData

extension User {
    public override func awakeFromNib() {
        super.awakeFromInsert()
        
        creationDate = Date()
    }
}
