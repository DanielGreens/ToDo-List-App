//
//  ViewController.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 11/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

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
    
    override func viewWillAppear(_ animated: Bool) {
        //Меняем цвет навигационного бара, перед тем как его увидит пользователь
        guard let color = selectedCategory?.colour else{return}
        
        title = selectedCategory!.name
        setStyleNavigationBar(hexCode: color)
    }
    
    //Метод вызывается когда текущее представление будет уничтожено, но если код смены цвета navigationBar поставить сюда, то при свайпе назад цвет будет меняться плавно, но если нажать кнопку назад на этом баре, то мы будем видеть переход от одного цвета к другому, это не очень хорошо, поэтому пользуемся методом willMove(toParent parent: UIViewController?)
    override func viewWillDisappear(_ animated: Bool) {
//        guard let originalColor = UIColor(hexString: "00A9D2") else { return }
//
//        setStyleNavigationBar(hexCode: originalColor.hexValue())
    }
    
    //Используем этот метод перехода к родителю, чтобы переход цвета навигационного бара был плавным не только при свайпе назад, но и если нажать на кнопку назад (< Список дел)
    override func willMove(toParent parent: UIViewController?) {
        guard let originalColor = UIColor(hexString: "00A9D2") else { return }
        
        setStyleNavigationBar(hexCode: originalColor.hexValue())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Чтобы изменения внешнего вида строки поиска вступили в силу, метод нужно вызвать здесь
        configurateSearcBar()
    }
    
    /// Устанавливает стиль для NavigationBar
    ///
    /// - Parameters:
    ///     - hexCode: hexCode цвета, в который мы хотим установить NavigationBar (Цвет текста будет контрастным, белым или черным.)
    private func setStyleNavigationBar(hexCode: String){
        guard let navBarColor = UIColor(hexString: hexCode) else {return}
        
        navigationController?.navigationBar.barTintColor = navBarColor
        navigationController?.navigationBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
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
        
        //Получаем ячейку из суперкласса. В нашем случае из класса SwipeTableViewController
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            //Здесь мы получаем цвет нашей родительской категории и относительного него, делаем цвета нашего списка темнее и темнее
            if let color = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        }
        else{
            cell.textLabel?.text = "Нету задач"
        }
        
        return cell
    }
    
//    Optional("#E57D22")
//    Optional("#BA661C")
//    Optional("#904E15")
//    Optional("#65370F")
//    Optional("#3B2008")
//    Optional("#100902")
    
    // MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        completeItem(at: indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)    //Погашаем выделение ячейки
    }
    
    // MARK: - Манипуляции с данными
    
    ///Загружает данные из Realm
    private func loadItems() {
        
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        self.tableView.reloadData()
    }
    
    /// Помечает задачу как выполненную или наоборот снимает пометку выполненно
    /// - Parameters:
    ///     - indexPath: Путь к индексу строки в таблице
    private func completeItem(at indexPath: IndexPath){
        
        //Если элемент массива не равен nil, то обновляем данные
        if let item = itemArray?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            }
            catch{
                print("Не получилось обновить данные - \(error.localizedDescription)")
            }
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Удаления данных по свайпу
    
    override func updateModel(at indexPath: IndexPath) {
        
        //Если элемент массива не равен nil, то обновляем данные
        if let item = self.itemArray?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(item) //Удаление объекта из БД
                }
            }
            catch{
                print("Не получилось удалить задачу - \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Методы для возможности удаления ячейки путем свайпа
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        var action = super.tableView(tableView, editActionsForRowAt: indexPath, for: orientation) ?? []
        
        //Проверяем чтобы свайп был с левой стороны, иначе возвращаем массив созданный супер классом
        guard orientation == .left else { return action }
        
        //Создаем действие для пометки задачи как выполненную
        let checkAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            
            //Здесь вызовется тот метод, который необходим, так как объект self  в нужный момент времени будет либо CategoryViewController либо ToDoListViewController. А так как в каждом из них переопределен метод updateModel, то вызовется именно тот который нужен.
            self.completeItem(at: indexPath)
        }
        
        configureSwipeAction(action: checkAction, with: .read)
        
        action.append(checkAction)
        
        return action
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
