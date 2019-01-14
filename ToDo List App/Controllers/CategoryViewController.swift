//
//  CategoryViewController.swift
//  ToDo List App
//
//  Created by Даниил Омельчук on 13/01/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "Нету ни одной категории"
        
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
        categories = realm.objects(Category.self)

        self.tableView.reloadData()
    }
}
