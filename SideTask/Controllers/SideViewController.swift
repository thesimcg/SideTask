//
//  SideViewController.swift
//  SideTask
//
//  Created by Simon McGrath on 06/02/2022.
//

import UIKit
import CoreData

class SideViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    
    var categories = [Category]()
    var sideTasks = [SideTask]()
    var categoryList = [String]()
    var shuffleList = [String]()
    var selectedIndex = 0
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSideTasks()
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]
        loadCategories(with: request)
        title = categoryList[selectedIndex]
    }
    

    //MARK: - Swipe Up
    
    @IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
        
        loadSideTasks()
        shuffleList.shuffle()
        if shuffleList.count == 0 {
            textView.text = "Add SideTasks first"
        }
        else {
            textView.text = shuffleList[0]
        }
    }


    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        
        selectedIndex += 1
        
        if selectedIndex == categoryList.count{
            selectedIndex = 0
        }
        title = categoryList[selectedIndex]
    }
    
    
    
    //MARK: - Load Categories and SideTasks
    
    func loadSideTasks(with request: NSFetchRequest<SideTask> = SideTask.fetchRequest(), predicate: NSPredicate? = nil) {
        
        request.predicate = predicate
        
        do {
            sideTasks = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        shuffleList.removeAll()
        
        if title == "All Categories" && selectedIndex == 0 {
            for sideTask in sideTasks{
                shuffleList.append(sideTask.displayTitle ?? "Empty")
           }
        } else {
            for sideTask in sideTasks{
                if sideTask.parentCategory?.displayTitle == title {
                    shuffleList.append(sideTask.displayTitle ?? "Empty")
                }
            }
        }
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest(), predicate: NSPredicate? = nil) {
        
        request.predicate = predicate
        
        do {
            categories = try context.fetch(request)
            
        } catch {
            print("Error loading categories: \(error)")
        }
        
        categoryList.removeAll()
        categoryList.append("All Categories")
        for category in categories{
            categoryList.append(category.displayTitle ?? "Empty")
       }
    }
}
