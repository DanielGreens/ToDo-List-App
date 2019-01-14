//
//  ItemRealm.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 13/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import Foundation
import RealmSwift

///Список задания для конкретной категории
class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done: Bool = false
    
    //Category.self - указываем что это именно тип Category, а не экземпляр класса Category
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") //Связь ссылка на родителя
}
