//
//  Item.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 11/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import Foundation

///Класс модели задачи
//Encodable - Это означает что наш класс теперь может зашифровать себя в plist или в Json. Чтобы этот протокол выполнялся, все типы свойств класса должны быть реализованны стандартными типами. Аналогично с Decodable
class Item : Encodable, Decodable {
    
    var title : String
    var done : Bool
    
    init() {
        title = ""
        done = false
    }
}
