//
//  UserDataHelper.swift
//
//  Created by CavanSu on 2020/4/20.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import CoreData

class UserDataHelper: NSObject {
    private var coreDataContext: NSManagedObjectContext!
    
    override init() {
        super.init()
        createSqlite()
    }
    
    func insert(_ user: BasicUserInfo) {
        let userData = NSEntityDescription.insertNewObject(forEntityName: "UserData",
                                                           into: coreDataContext) as! UserData
        
        userData.name = user.name
        userData.userId = user.userId
        
        try! coreDataContext.save()
    }
    
    func modify(_ user: BasicUserInfo) {
        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", "userId", user.userId)
        request.predicate = predicate
        
        do {
            let result = try coreDataContext.fetch(request)
            
            for item in result {
                item.name = user.name
            }
            
            try coreDataContext.save()
        } catch  {
            fatalError()
        }
    }
    
    func fetch(_ userId: String) -> UserData? {
        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", "userId", userId)
        request.predicate = predicate
        do {
            let result = try coreDataContext.fetch(request)
            return result.first
        } catch  {
            return nil
        }
    }
}

private extension UserDataHelper {
    func createSqlite() {
        guard let modelURL = Bundle.main.url(forResource: "AgoraVoice", withExtension: "momd") else {
            fatalError()
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError()
        }
        
        let store = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        guard let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                  .userDomainMask,
                                                                  true).last else {
            fatalError()
        }
         
        let folder = documents + "/LocalStorage"
        FilesGroup.check(folderPath: folder)
        let sqlURL = URL(fileURLWithPath: (folder + "/AgoraVoice.sqlite"))
        
        try! store.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqlURL, options: nil)
        
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = store
        coreDataContext = context
    }
}


