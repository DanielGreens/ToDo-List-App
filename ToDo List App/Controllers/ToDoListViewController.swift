//
//  ViewController.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 11/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    //Так как мы храним список объектов типа который мы сами создали для хранения данных нам не подходит стандартный User.defaults. Мы создали свой Items.plist
    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Получаем путь к папке на данном ПК, где хранятся наши данные для Items.plist
//        print(dataFilePath!)
        
        loadItems()
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
            
            self.saveItems()
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
        
        saveItems()
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)    //Погашаем выделение ячейки
    }
    
    // MARK: - Манипуляции с данными
    
    ///Сохраняет данные в Items.plist
    private func saveItems(){
        let encoder = PropertyListEncoder()
        
        do{
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        }
        catch{
            print("Ошибка в сохранении данных - \(error.localizedDescription)")
        }
        
        self.tableView.reloadData()
    }
    
    ///Загружает данные из Items.plist
    private func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do{
                itemArray = try decoder.decode([Item].self, from: data) //[Item].self - Указываем что это именно тип Item, а не экземпляр класса. Например Someclass.self возвращает сам Someclass, а не экземпляр Someclass
            }
            catch {
                print("Ошибка в загрузке данных - \(error.localizedDescription)")
            }
        }
    }
    
}

