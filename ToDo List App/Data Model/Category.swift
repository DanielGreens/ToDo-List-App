//
//  CategoryRealm.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 13/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import Foundation
import RealmSwift

///Категория, тоесть название списка
class Category: Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()    //Связь один ко многим
}
