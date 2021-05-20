//
//  Pin + Extension.swift
//  VirtualTouristApp
//
//  Created by June2020 on 5/19/21.
//

import Foundation
import CoreData

extension Pin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
