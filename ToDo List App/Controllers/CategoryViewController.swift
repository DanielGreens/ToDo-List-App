//
//  CategoryViewController.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 13/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    ///Объект для записи и чтения данных из БД
    let realm = try! Realm()

    var categories: Results<Category>!  //Запросы возвращают из БД Realm данные типа Results<>. Они обновляются автоматически, в результате нам не нужно в ручную добавлять в нее элементы
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }
    
    // MARK: - Add new Category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()   //Создаем текстовое поле, чтобы мы могли отслеживать набранный пользователем текст
        
        let alert = UIAlertController(title: "Добавьте новую категорию", message: nil, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Добавить", style: .default) { (action) in
            //Что должно произойти если пользователь нажмет добавить задачу
            
            let newCategory = Category()
            newCategory.name = textField.text!
            //lighten(byPercentage: 0.3) - осветляем полуенный цвет на 30% чтобы темный текст был читаем
            newCategory.colour = (UIColor.randomFlat.lighten(byPercentage: 0.3)?.hexValue())!
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Новая категория"
            alertTextField.autocapitalizationType = .sentences  //Начинаем писать с заглавной буквы
            textField = alertTextField
        }
        
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Получаем ячейку из суперкласса. В нашем случае из класса SwipeTableViewController
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        cell.textLabel?.text = categories?[indexPath.row].name ?? "Нету ни одной категории"
        
        //Добавляем рандомный цвет ячейке с помозью фреймворка Chameleon
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].colour ?? "00A9D2")

        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Data Manipulation Methods
    
    ///Сохраняет данные в БД (Realm)
    private func save(category: Category){
        do{
            try realm.write {
                realm.add(category)
            }
        }
        catch{
            print("Ошибка в сохранении категории - \(error.localizedDescription)")
        }
        self.tableView.reloadData()
    }
    
    ///Загружает данные из БД (Realm)
    private func loadCategories() {
        
        //Возвращает все обЪекты из БД заданного типа
        categories = realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)

        self.tableView.reloadData()
    }
    
    // MARK: - Удаления данных по свайпу
    
    override func updateModel(at indexPath: IndexPath) {
        
        //Если элемент массива не равен nil, то обновляем данные
        if let item = self.categories?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(item) //Удаление объекта из БД
                }
            }
            catch{
                print("Не получилось удалить категорию - \(error.localizedDescription)")
            }
        }
    }
}
