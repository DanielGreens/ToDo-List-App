//
//  ViewController.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 11/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController, UISearchBarDelegate {

    //Так как мы храним список объектов типа который мы сами создали для хранения данных нам не подходит стандартный User.defaults. Мы создали свой Items.plist
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet{
            //Вызываем загрузку только когда мы уже знаем выбранную категорию, чтобы наше приложение не упало
            loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let searchController = UISearchController(searchResultsController: nil)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Получаем путь к папке на данном ПК, где хранятся наши данные для DataModel
        //        print(dataFilePath)
        
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
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.parentCategory = self.selectedCategory
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
        
        //Удаление из CoreData
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        saveItems()
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)    //Погашаем выделение ячейки
    }
    
    // MARK: - Манипуляции с данными
    
    ///Сохраняет данные в DataModel (CoreData)
    private func saveItems(){
        
        do{
            try context.save()
        }
        catch{
            print("Ошибка в сохранении данных - \(error.localizedDescription)")
        }
        
        self.tableView.reloadData()
    }
    
    ///Загружает данные из DataModel (CoreData)
    /// - Parameters:
    ///     - with: Запрос по которому будут возвращены данные. По умолчанию возвращает все записи
    ///     - predicate: Предикат, по которому производится поиск
    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        //Предикат поиска задач для выбранной категории
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        //В данном случае у нас массив предикатов, так как мы должны искать только по тем элементам, который относяться к выбранной категории и не пересекаться с другими
        if let additionalPredicate = predicate {
            //Проверяем, если передали дополнительный предикат (поиск), то компонуем их, иначе будем получать просто все задачи для заданной категории
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }
        else{
            request.predicate = categoryPredicate
        }
        
        do{
            itemArray = try context.fetch(request)
        }
        catch{
            print("Ошибка в загрузке данных - \(error.localizedDescription)")
        }
        
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
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            
            //Сортируем полученный результат по полю title по возрастанию
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            //[cd] -> с - означает что мы не обращаем внимание на регистр. d - означает что мы игнорируем специальные символы и приравниваем их к обычным Подробнее в NSPredicateCheatsheet.pdf
            loadItems(with: request, predicate: NSPredicate(format: "title CONTAINS[cd] %@", searchText))
        }
        //Иначе загружаем весь список
        else{
            loadItems()
        }
    }
}
