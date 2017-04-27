//
//  ViewController.swift
//  CoreDataSearch
//
//  Created by Vamshi Krishna on 27/04/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import UIKit

import CoreData

class ViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout , TapCellDelegate, UISearchBarDelegate, UISearchControllerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionSearchBar: UISearchBar!
    var cellIdentifier = "Cell"
    var numberOfItemsPerRow : Int = 2
    var searchBarActive:Bool = false
    var items:[NSManagedObject] = []
    var filteredItems:[NSManagedObject] = []
    var filteredItemsIndices: [Int] = []
    
    var cellWidth:CGFloat{
        return collectionView.frame.size.width/2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionSearchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Item")
        do {
            items = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    // MARK: Search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            self.searchBarActive    = true
            myFetchRequest(searchString: searchBar.text!)
        }else{
            self.searchBarActive = false
            self.collectionView?.reloadData()
        }
    }
    
    func myFetchRequest(searchString: String)
    {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        filteredItems.removeAll(keepingCapacity: false)
        filteredItemsIndices.removeAll(keepingCapacity: false)
        let myRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        myRequest.predicate = NSPredicate(format: "itemId CONTAINS[cd] %@", searchString)
        do{
            let results = try managedObjectContext.fetch(myRequest)
            for result in results
            {
                filteredItems.append(result as! NSManagedObject)
                filteredItemsIndices.append(items .index(of: result as! NSManagedObject)!)
            }
            self.collectionView?.reloadData()
        } catch let error{
            print(error)
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self .cancelSearching()
        self.collectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarActive = true
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.collectionSearchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBarActive = false
        self.collectionSearchBar.setShowsCancelButton(false, animated: false)
    }
    
    func cancelSearching(){
        self.searchBarActive = false
        self.collectionSearchBar.resignFirstResponder()
        self.collectionSearchBar.text = ""
    }
    
    // MARK: <UICollectionViewDataSource>
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CollectionViewCell
            cell.delegate = self
            cell.layer.borderWidth = 1.0
            cell.indexPath = indexPath
            cell.layer.borderColor = UIColor.blue.cgColor
            
            if(!searchBarActive){
                cell.itemIdLabel.text = self.items[indexPath.row].value(forKeyPath: "itemId") as? String
            }
            else{
                cell.itemIdLabel.text = self.filteredItems[indexPath.row].value(forKeyPath: "itemId") as? String
            }
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(!self.searchBarActive){
           return items.count
        }
        else{
            return filteredItems.count
        }
    }
    
    func buttonTapped(indexPath: IndexPath) {
        
        let alert=UIAlertController(title: "Hello", message: "Are you sure you want to deliver this parcel?", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil));
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
           
            if(self.filteredItemsIndices.count > 0){
                self.deleteItem(indexOfItem: self.filteredItemsIndices[indexPath.row])
            }
            else{
                self.deleteItem(indexOfItem: indexPath.row)
            }
        }));
        present(alert, animated: true, completion: nil);
    }
    
    
    func deleteItem (indexOfItem : Int){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let item = items[indexOfItem]
        managedContext.delete(item)
       
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Item")
        do {
            items = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        self.collectionSearchBar.text = ""
        self.collectionView.reloadData()
        
    }
    // MARK: <UICollectionViewDelegateFlowLayout>
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        return CGSize(width: size, height: size)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    @IBAction func parkClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Please Enter The Details", message: nil, preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "Item ID:(A-Z,a-z,0-9)"
            $0.keyboardType = UIKeyboardType.default
            $0.addTarget(alert, action: #selector(alert.textDidChangeInEnteringItem), for: .editingChanged)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let parkAction = UIAlertAction(title: "Park", style: .default) { [unowned self] _ in
            guard let itemId = alert.textFields?[0].text
                else {
                    return
            }
            self.parkItem(itemId: itemId)
        }
        
        parkAction.isEnabled = false
        alert.addAction(parkAction)
        present(alert, animated: true)
    }
    
    func parkItem(itemId:String) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Item",
                                       in: managedContext)!
        let item = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
    
        
        item.setValue(itemId, forKeyPath: "itemId")
        items.append(item)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        self.collectionView.reloadData()
        self.collectionView.scrollToItem(at: IndexPath(item: items.count-1, section: 0), at: [], animated: false)
    }
}




extension UIAlertController {
    
    func isValidId(_ itemId: String) -> Bool {
        return itemId.characters.count > 0 && NSPredicate(format: "self matches %@", "[a-zA-Z0-9]*$").evaluate(with: itemId)
    }
    
    func textDidChangeInEnteringItem() {
        if let itemId = textFields?[0].text,
            let action = actions.last {
            action.isEnabled = isValidId(itemId)
        }
    }
}

