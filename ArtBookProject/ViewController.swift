//
//  ViewController.swift
//  ArtBookProject
//
//  Created by Kaan Yıldız on 19.01.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var myTableView: UITableView!
    var paintingNameARRAY = [String]()
    var idARRAY = [UUID]()
    
    var selectedPaintingID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.dataSource = self
        myTableView.delegate = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goAddPaintingVc))
        
        fetchDataFromCD()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchDataFromCD), name: NSNotification.Name("new painting arranged"), object: nil)
    }
    
    @objc func fetchDataFromCD(){
        
        // doublicate işlemi olmasın diye her seferinde bu arrayleri boşaltmalıyım.
        // ZAten fetchRequest ile tüm paintingleri yeniden çağırıyorum her seferinde.
        paintingNameARRAY.removeAll()
        idARRAY.removeAll()
        
        // bu iki satır projede appDel.. dosyasındaki bir değişkene ulaşmak için var
        let apDelegate = UIApplication.shared.delegate as! AppDelegate
        let content = apDelegate.persistentContainer.viewContext
        
        // obje kümesini çekmek istediğim entity (class) neyse onun ismi ile Fetchrequest değişkeni oluşturmak zorundayım.
        let FetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        FetchRequest.returnsObjectsAsFaults = false  // bu satır neden var bilmiyorum.
        
        do{
            let results = try content.fetch(FetchRequest)    // content den çek işlemi istiyorum
            if !results.isEmpty {
                
                // döndürdüğü şey ismini verdiğim entity nin tüm Objeleri +
                for result in results as! [NSManagedObject]{
                    
                    // 1 objenin belli atribute larını tutmak istiyorum..
                    if let paintingName = result.value(forKey: "paintingName") as? String {
                        paintingNameARRAY.append(paintingName)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        idARRAY.append(id)
                    }
                    
                    // table view u yeniden yükle li değişiklikleri görelim.
                    myTableView.reloadData()
                    
                }
            }
            
        }catch {
            print("error wile fetching")
        }
        
    }
    
    
    
    @objc func goAddPaintingVc(){
        selectedPaintingID = nil
        performSegue(withIdentifier: "ToAddPaintingVC", sender: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paintingNameARRAY.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell = UITableViewCell()
        var content = Cell.defaultContentConfiguration()
        content.text = paintingNameARRAY[indexPath.row]
        //content.secondaryText = idARRAY[indexPath.row].uuidString
        Cell.contentConfiguration = content
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPaintingID = idARRAY[indexPath.row].uuidString
        performSegue(withIdentifier: "ToAddPaintingVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAddPaintingVC" {
            if let destination = segue.destination as? AddNewPaintingVC {
                destination.ChoosenPaintingID = selectedPaintingID
            }
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // bu method tableView umdaki satırları kaydırdığımda delete çıkmasını sağlayan method.
        
        if editingStyle == .delete {
            
            let apDelegate = UIApplication.shared.delegate as! AppDelegate
            let content = apDelegate.persistentContainer.viewContext

            let myFetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = idARRAY[indexPath.row].uuidString
            // çekmek isteğime detay ekliyorum; id atribute u idString olan şeyi çek diyorum.
            myFetchReq.predicate = NSPredicate(format: "id = %@", idString)
            myFetchReq.returnsObjectsAsFaults = false
            
            do{
                let results = try content.fetch( myFetchReq )
                
                if !results.isEmpty {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            //köprüden önceki son çıkış kontrolü.
                            if id == idARRAY[indexPath.row]{
                                content.delete(result)
                                // bir eleman silince tableView un şaftı kaymasın, toparlayalım
                                paintingNameARRAY.remove(at: indexPath.row)
                                idARRAY.remove(at: indexPath.row)
                                tableView.reloadData()
                                
                                try content.save()
                                
                                break
                            }
                            
                        }
                        
                    }
                }
                
                
                
            }catch {
                print("error")
            }
                
            
                
            
            
        }
    }
    
    

}

