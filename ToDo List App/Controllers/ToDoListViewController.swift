//
//  ViewController.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 11/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem = Item()
        newItem.title = "Сделать приложение"
        itemArray.append(newItem)

        let newItem2 = Item()
        newItem2.title = "Купить молоко"
        itemArray.append(newItem2)

        let newItem3 = Item()
        newItem3.title = "Убрать комнату"
        itemArray.append(newItem3)
        
        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            itemArray = items
        }
        
    }
    
    // MARK: - Button Action
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()   //Создаем текстовое поле, чтобы мы могли отслеживать набранный пользователем текст
        
        let alert = UIAlertController(title: "Новая задача", message: nil, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Добавить задачу", style: .default) { (action) in
            //Что должно произойти если пользователь нажмет добавить задачу
            
            let newItem = Item()
            newItem.title = textField.text!
            self.itemArray.append(newItem)
            
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Создайте новую задачу"
            alertTextField.autocapitalizationType = .sentences  //Начинаем писать с заглавной буквы
            textField = alertTextField
        }
        
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
    }
    

    // MARK: - Tableview Datasourse Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    
    // MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Этот способ работает корректно только при маленьком количестве строк в таблице, если их будет больше чем может поместиться на экран, то выбрав первую ячейку, прокручивая ниже мы увидим что у ячейки которую мы не выбирали тоже появится .checkmark, все из за того что ячейки переиспользуются, а .checkmark у каждой ячейки не зависим, и если он был выбран то при переиспользовании этой ячейки он останется выбранным
        //tableView.cellForRow(at: indexPath)?.accessoryType = tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark ? .none : .checkmark
        
        //Чтобы этого избежать мы создали модель данных Item, в которой мы храним свойство говорящее была ли выбрана эта ячейка или нет. И присваиваем значение .accessoryType в методе выше, который вызывается при инициализации ячеек
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)    //Погашаем выделение ячейки
    }
    
}

