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
    
    var shuffleTasks = [SideTask]()
    var shuffleList = [String]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request : NSFetchRequest<SideTask> = SideTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]
        loadShuffleTasks(with: request)
        
        print("Shuffle Tasks:")
        for sideTask in self.shuffleTasks {
            print(sideTask.displayTitle ?? "NULL")
        }
    }
    

    @IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
        
        loadShuffleTasks()
        shuffleList.shuffle()
        if shuffleList.count == 0 {
            textView.text = "Add SideTasks first"
        }
        else {
            textView.text = shuffleList[0]
        }
    }

    
    //MARK: - Load
    
    func loadShuffleTasks(with request: NSFetchRequest<SideTask> = SideTask.fetchRequest(), predicate: NSPredicate? = nil) {
        
        request.predicate = predicate
        
        do {
            shuffleTasks = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        shuffleList.removeAll()
        for sideTask in shuffleTasks{
            shuffleList.append(sideTask.displayTitle ?? "Empty")
       }
    }
}
