//
//  UserData+CoreDataProperties.swift
//  
//
//  Created by CavanSu on 2020/4/20.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var name: String?
    @NSManaged public var userId: String?

}
