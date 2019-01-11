//
//  ViewController.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 11/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    var itemArray = ["Сделать приложение", "Купить молоко", "Убрать комнату"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - Button Action
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()   //Создаем текстовое поле, чтобы мы могли отслеживать набранный пользователем текст
        
        let alert = UIAlertController(title: "Новая задача", message: nil, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Добавить задачу", style: .default) { (action) in
            //Что должно произойти если пользователь нажмет добавить задачу
            self.itemArray.append(textField.text!)
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Создайте новую задачу"
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
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    // MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.accessoryType = tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark ? .none : .checkmark
        
        tableView.deselectRow(at: indexPath, animated: true)    //Погашаем выделение ячейки
    }
    
}

