//
//  SwipeShared.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 15/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

///Настройка внешнего вида иконок действий по свайпу
enum ActionDescriptor {
    case read, unread, more, flag, trash
    
    /// Устанавливает текст для действия в соответствии с enum
    ///
    /// - Parameters:
    ///     - displayMode: Текст описания для действия (.trash -> текст под икнокой будет Delete)
    /// - Returns:
    ///     Возвращает соответствующую перечислению строку
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        //Если надо отобразить только изобраджение то сразу выходим отсюда
        guard displayMode != .imageOnly else { return nil }
        
        //Иначе возвращаем соответствующий текст
        switch self {
        case .read: return "Ckeck"
        case .unread: return "Uncheck"
        case .more: return "More"
        case .flag: return "Flag"
        case .trash: return "Delete"
        }
    }
    
    /// Устанавливает иконку для действия в соответствии с enum
    ///
    /// - Parameters:
    ///     - style: Стиль кнопки (Обычная с цветом фона или скругленная)
    ///     - displayMode: Как будем отображать кнопку (Просто иконка или иконка с текстом)
    /// - Returns:
    ///     Возвращаемое значение
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        //Если надо отобразить только текст то сразу выходим отсюда
        guard displayMode != .titleOnly else { return nil }
        
        //Иначе устанавливаем икноку в соответствии с ее именем
        let name: String
        switch self {
        case .read: name = "check"
        case .unread: name = "Unread"
        case .more: name = "More"
        case .flag: name = "Flag"
        case .trash: name = "delete-icon"
        }
        
        //Если выбран режим отображения скругленной кнопки (.circular), то добавляем к имени икноки circle, чтобы подставить нужную
        return UIImage(named: style == .backgroundColor ? name : name + " circle")
    }
    
    ///Цвет фона для действия
    var color: UIColor {
        switch self {
        case .read, .unread: return #colorLiteral(red: 0, green: 0.4577052593, blue: 1, alpha: 1)
        case .more: return #colorLiteral(red: 0.7803494334, green: 0.7761332393, blue: 0.7967314124, alpha: 1)
        case .flag: return #colorLiteral(red: 1, green: 0.5803921569, blue: 0, alpha: 1)
        case .trash: return #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
        }
    }
}

/// Как отображать кнопку
enum ButtonDisplayMode {
    /// Заголовок и изображение
    case titleAndImage,
    /// Только заголовок
         titleOnly,
    /// Только изображение
         imageOnly
}

/// Стиль кнопки
enum ButtonStyle {
    /// Кнопки с цветом фона
    case backgroundColor,
    /// Скругленная кнопка
    circular
}
