//
//  SwipeTableViewController.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 14/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import SwipeCellKit

//Общий класс для наших контроллеров, который дает возможность путем свайпа удалять ячейки

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .circular
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //as! SwipeTableViewCell - Реализуем поддержку свайпа по ячейке для ее возможного удаления
        //Мы так же переименовали идентификаторы ячеек у обоих контроллеров в Cell, так как мы хотим добавить этот функционал ко всем ячейкам
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - Методы для возможности удаления ячейки путем свайпа
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        //Проверяем чтобы свайп был с правой стороны
        guard orientation == .right else { return nil }
        
        //Создаем действие для удаления ячейки
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            
            //Здесь вызовется тот метод, который необходим, так как объект self  в нужный момент времени будет либо CategoryViewController либо ToDoListViewController. А так как в каждом из них переопределен метод updateModel, то вызовется именно тот который нужен.
            self.updateModel(at: indexPath)
        }
        
        configureSwipeAction(action: deleteAction, with: .trash)
        
        return [deleteAction]
    }
    
    //Потянули сильнее и удалили строку
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        
        //Если потянули слева то выбираем действие как .selection иначе это удаление
        options.expansionStyle = orientation == .left ? .selection : .destructive
        
        //Настраиваем внешний вид кнопки в соответствии с выбранным стилем
        switch buttonStyle {
            
        case .backgroundColor:
            options.buttonSpacing = 11
        case .circular:
            options.buttonSpacing = 4
            options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
        }
        
        return options
    }
    
    /// Настройка внешнего вида действия по свайпу
    ///
    /// - Parameters:
    ///     - action: Действие по свайпу
    ///     - descriptor: Что это за кнопка
    func configureSwipeAction(action: SwipeAction, with descriptor: ActionDescriptor) {
        
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color
            action.font = .systemFont(ofSize: 13)
            action.transitionDelegate = ScaleTransition.default
        }
    }
    
    /// Обновляет данные в БД
    /// - Parameters:
    ///     - indexPath: Путь к индексу строки в таблице
    public func updateModel(at indexPath: IndexPath){
        //Обновляем данные
    }
    
}
