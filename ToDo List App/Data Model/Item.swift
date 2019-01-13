//
//  Item.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 13/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import Foundation
import CoreData

public class Item : NSManagedObject {
    
    //Переопределяем инициализатор, который мы вынуждены вызвать в инициализаторе выше, иначе приложение упадет
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    ///Инициализатор который устанавливает значение по умолчанию
    //В нашем случае это делается чтобы свойству done было присвоено значение false при добавлении новой задачи
    init(context: NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: context);
        super.init(entity: entity!, insertInto: context)
        done = false
        title = ""
    }
}
