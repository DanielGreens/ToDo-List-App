//
//  ViewController.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 11/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController, UISearchBarDelegate {

    ///Объект для записи и чтения данных из БД
    let realm = try! Realm()
    
    //Теперь мы делаем тип Results, так как этот тип возвращается Realm
    var itemArray: Results<Item>?
    
    var selectedCategory : Category? {
        didSet{
            //Вызываем загрузку только когда мы уже знаем выбранную категорию, чтобы наше приложение не упало
            loadItems()
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Помещаем контроллер поиска в NavigationBar
        navigationItem.searchController = searchController
        //Если true, то мы гарантируем что панель поиска не останется на экране, если пользователь перейдет к другому контроллеру представления
        definesPresentationContext = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Чтобы изменения внешнего вида строки поиска вступили в силу, метод нужно вызвать здесь
        configurateSearcBar()
    }
    
    // MARK: - Button Action
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()   //Создаем текстовое поле, чтобы мы могли отслеживать набранный пользователем текст
        
        let alert = UIAlertController(title: "Новая задача", message: nil, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Добавить задачу", style: .default) { (action) in
            //Что должно произойти если пользователь нажмет добавить задачу
            
            //Сохраняем данные в Realm
            if let currentCategory = self.selectedCategory {
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                }
                catch{
                    print("Ошибка в сохранении Items в Realm - \(error.localizedDescription)")
                }
            }
            
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
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as UITableViewCell
        
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }
        else{
            cell.textLabel?.text = "Нету задач"
        }
        
        return cell
    }
    
    // MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Если элемент массива не равен nil, то обновляем данные
        if let item = itemArray?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
//                    realm.delete(item) //Удаление объекта из БД
                }
            }
            catch{
                print("Не получилось обновить данные - \(error.localizedDescription)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)    //Погашаем выделение ячейки
    }
    
    // MARK: - Манипуляции с данными
    
    ///Загружает данные из Realm
    private func loadItems() {
        
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        self.tableView.reloadData()
    }
    
}


// MARK: - Методы поиска
extension ToDoListViewController: UISearchResultsUpdating {
    
    ///Настраиваем внешний вид SearchBar
    private func configurateSearcBar() {
        searchController.searchResultsUpdater = self
        //Если поставить true, то мы не сможем взаимодействовать с таблицей, пока вводим строку поиска
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        searchController.searchBar.barTintColor = .white
        
        //Настраиваем текстовое поле SearchBar
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            //Меняем цвет placeHolder на белый
            textField.attributedPlaceholder = NSAttributedString(string: "Поиск...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            textField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            //Меняем цвет иконки лупы на белый
            let iconView = textField.leftView as! UIImageView
            iconView.image = iconView.image?.withRenderingMode(.alwaysTemplate)
            iconView.tintColor = .white
            
            //Меняем цвет кнопки очистки содержимого строки поиска на белый
            let clearButton = textField.value(forKey: "clearButton") as? UIButton
            clearButton?.setImage(clearButton?.currentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            clearButton?.tintColor = .white
        }
    }
    
    //Сюда мы попадаем каждый раз когда пользователь печатает новый символ
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    /// Проверяет строку поиска на пустую строку
    /// - Returns:
    ///     true - если строка пустая
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    
    ///Фильтрует контент в соответствии с строкой поиска
    ///
    /// - Parameters:
    ///     - searchText: Строка поиска
    private func filterContentForSearchText(_ searchText: String) {
        
        //Если строка поиска не пустая загружаем совпадения
        if !searchBarIsEmpty(){
            
            //[cd] -> с - означает что мы не обращаем внимание на регистр. d - означает что мы игнорируем специальные символы и приравниваем их к обычным Подробнее в NSPredicateCheatsheet.pdf
            //Сортируем полученный результат по полю title по возрастанию
            itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "title", ascending: true)
            
            tableView.reloadData()
        }
        //Иначе загружаем весь список
        else{
            loadItems()
        }
    }
}
