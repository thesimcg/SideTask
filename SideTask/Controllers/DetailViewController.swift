//
//  DetailViewController.swift
//  SideTask
//
//  Created by Simon McGrath on 31/12/2021.
//

import UIKit
import CoreData

class DetailViewController: UITableViewController {
    
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    
    var sideTasks = [SideTask]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? {
        
        didSet{
            loadSideTasks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let newTitle = selectedCategory!.displayTitle {
            title = "\(newTitle)"
        }
        
        let request : NSFetchRequest<SideTask> = SideTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]
        loadSideTasks(with: request)
        
    }

    // MARK: - TableView Setup
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideTask", for: indexPath)
        
        let sideTask = sideTasks[indexPath.row]
        
        cell.textLabel?.text = "\(sideTask.displayTitle!)"
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        return cell
    }
    
    
    //MARK: - Did Select Row
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !isEditing {
            saveSideTasks()
            tableView.deselectRow(at: indexPath, animated: true)

        } else {
            var titleTextField = UITextField()

                    let alert = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)

                    let action = UIAlertAction(title: "Confirm", style: .default) { (action) in

                        self.sideTasks[indexPath.row].displayTitle = titleTextField.text!
                        self.saveSideTasks()
                    }

                    alert.addAction(action)

                    let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                    alert.addAction(cancel)

                    alert.addTextField { (titleField) in
                        titleTextField = titleField
                        titleField.autocapitalizationType = .sentences
                        
                        if let name = self.sideTasks[indexPath.row].displayTitle {
                            titleField.placeholder = "\(String(describing: name))"
                            titleField.text = "\(String(describing: name))"
                        } else {
                            titleField.placeholder = "New Name"
                        }
                    }
                    present(alert, animated: true)
        }
    }
    
    //MARK: - Delete Row
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            context.delete(sideTasks[indexPath.row])
            sideTasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            saveSideTasks()
        }
    }
   
    //MARK: - Add New SideTask
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var titleTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New SideTask", message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add SideTask", style: .default) { (action) in
            
            let newSideTask = SideTask(context: self.context)
            
            
            newSideTask.createdAt = Date()
            newSideTask.updatedAt = Date()
            newSideTask.displayOrder = Int64(self.sideTasks.count)
            newSideTask.uniqueID = "STC\(String(Date().hashValue))"
            newSideTask.displayTitle = titleTextField.text!
            newSideTask.parentCategory = self.selectedCategory
            
            self.sideTasks.append(newSideTask)
            self.saveSideTasks()
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        
        alert.addTextField { (alertTextField) in
            alertTextField.autocapitalizationType = .sentences
            alertTextField.placeholder = "Create new SideTask"
            titleTextField = alertTextField
            
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    //MARK: - Edit and Move Rows
    
    @IBAction func toggleEditing(_ sender: UIBarButtonItem) {
        isEditing = !isEditing
        
        if isEditing {
            editButton.title = "Done"
        } else {
            editButton.title = "Edit"
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = sideTasks[sourceIndexPath.row]
        sideTasks.remove(at: sourceIndexPath.row)
        sideTasks.insert(itemToMove, at: destinationIndexPath.row)
        
        reorderSideTasks()
        saveSideTasks()
    }

    
    //MARK: - Reorder
    
    func reorderSideTasks() {
        
        let newArrayOrder = sideTasks
        var newDisplayOrder = 0
        
        for i in newArrayOrder {
            i.displayOrder = Int64(newDisplayOrder)
            newDisplayOrder += 1
        }
        
        sideTasks = newArrayOrder
    }
    
    //MARK: - Save and Load
    
    func saveSideTasks() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadSideTasks(with request: NSFetchRequest<SideTask> = SideTask.fetchRequest(), predicate: NSPredicate? = nil) {
        
        request.predicate = NSPredicate(format: "parentCategory.uniqueID MATCHES %@", selectedCategory!.uniqueID!)
        
        do {
            sideTasks = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        tableView.reloadData()
    }
}
