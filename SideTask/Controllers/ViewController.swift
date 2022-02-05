//
//  ViewController.swift
//  SideTask
//
//  Created by Simon McGrath on 18/11/2021.
//

import UIKit
import CoreData

class ViewController: UITableViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let request : NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]
        loadCategories(with: request)
        
        for category in self.categories {
            print(category.uniqueID ?? "NULL")
            print(category.displayTitle ?? "NULL")
            print(category.displayOrder)
            print(category.createdAt ?? "NULL")
            
        }
        
    }
    
    //MARK: - TableView Setup
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Category", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].displayTitle
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        return cell
    }

    //MARK: - Add New Category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var titleTextField = UITextField()
        
        let alert = UIAlertController(title: "Add:", message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Create", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            
            newCategory.createdAt = Date()
            newCategory.updatedAt = Date()
            newCategory.displayOrder = 0
            newCategory.uniqueID = "STC\(String(Date().hashValue))"
            newCategory.displayTitle = titleTextField.text!
//            if titleTextField.text?.isEmpty = nil {
//                newCategory.displayTitle = newCategory.uniqueID
//            } else {
//                newCategory.displayTitle = titleTextField.text!
//            }
            
            for category in self.categories {
                category.displayOrder += 1
            }
            self.categories.insert(newCategory, at: 0)
            self.saveCategories()
        }
        
        alert.addAction(action)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cancel)
        
        alert.addTextField { (titleField) in
            titleTextField = titleField
            titleField.autocapitalizationType = .sentences
            titleField.placeholder = "Category"
        }
        
        present(alert, animated: true)
        
    }
    
    //MARK: - Did Select Row
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !isEditing {
            
            performSegue(withIdentifier: "goToDetail", sender: self)

        } else {

            var titleTextField = UITextField()

                    let alert = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)

                    let action = UIAlertAction(title: "Confirm", style: .default) { (action) in

                        self.categories[indexPath.row].displayTitle = titleTextField.text!
                        self.saveCategories()
                    }

                    alert.addAction(action)

                    let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                    alert.addAction(cancel)

                    alert.addTextField { (titleField) in
                        titleTextField = titleField
                        titleField.autocapitalizationType = .sentences
                        
                        if let name = self.categories[indexPath.row].displayTitle {
                            titleField.placeholder = "\(String(describing: name))"
                            titleField.text = "\(String(describing: name))"
                        } else {
                            titleField.placeholder = "New Name"
                        }
                    }

                    present(alert, animated: true)
        }
    }
    
    //MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DetailViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    //MARK: - Delete Row
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            context.delete(categories[indexPath.row])
            categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
            reorderCategories()
            saveCategories()
        }
    }
    
    //MARK: - Edit and Move Rows
    
    @IBAction func startEditing(_ sender: Any) {
        isEditing = !isEditing
        if isEditing {
            editButton.title = "Done"
        } else {
            editButton.title = "Edit"
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = categories[sourceIndexPath.row]
        categories.remove(at: sourceIndexPath.row)
        categories.insert(itemToMove, at: destinationIndexPath.row)
        
        reorderCategories()
        saveCategories()
    }
    
    //MARK: - Reorder
    
    func reorderCategories() {
        
        let newArrayOrder = categories
        var newDisplayOrder = 0
        
        for i in newArrayOrder {
            i.displayOrder = Int64(newDisplayOrder)
            newDisplayOrder += 1
        }
        
        categories = newArrayOrder
    }
        
    //MARK: - Save and Load
        
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving category: \(error)")
        }
        tableView.reloadData()
    }
        
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest(), predicate: NSPredicate? = nil) {
        
        request.predicate = predicate
        
        do {
            categories = try context.fetch(request)
            
        } catch {
            print("Error loading categories: \(error)")
        }
        
        tableView.reloadData()
    }

}
