//
//  AddNewPaintingVC.swift
//  ArtBookProject
//
//  Created by Kaan Yıldız on 20.01.2023.
//

import UIKit
import CoreData

class AddNewPaintingVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    @IBOutlet var newPainting: UIImageView!
    @IBOutlet var artistTextF: UITextField!
    @IBOutlet var paintingNameTextF: UITextField!
    @IBOutlet var madeYearTextF: UITextField!
    @IBOutlet var saveButton: UIButton!
    
    var ChoosenPaintingID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ChoosenPaintingID != nil {
            // core data dan tıkladığım paintingName in id si ile veri çek,
            // çektiğin veriyi aynı VC üzerinde göster. İkinci VC oluşturmak istemiyoruz çünkü.
            saveButton.isHidden = true
            artistTextF.isUserInteractionEnabled = false
            paintingNameTextF.isUserInteractionEnabled = false
            madeYearTextF.isUserInteractionEnabled = false
            
            showPainting()
            
        }else {
            saveButton.isEnabled = false
            // artı butonuna basılınca olması gerekenler otomatikman olsun zaten..
            newPainting.isUserInteractionEnabled = true
            let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(goPhoneLibrary))
            newPainting.addGestureRecognizer(gestureRecognizer2)
            
        }
        

        // klavyeden istenmediği zaman kurtulmak için bunları yazman gerekmekte.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector( hideKeyboard ))
        view.addGestureRecognizer(gestureRecognizer)
        
        
        
    }
    
    func showPainting(){
        // tech işlemi gerçekleştireceğim elimde bulundurduğum id ye sahip paintings entity sini objesini.
        let apDelegate = UIApplication.shared.delegate as! AppDelegate
        let content = apDelegate.persistentContainer.viewContext
        
        let myFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        
        // Bu satır Fetch ime şart koşuyor. Çekeceğin şeyin id atribute u virgülden sonra şu olsun diyor.
        myFetchRequest.predicate = NSPredicate(format:"id = %@", ChoosenPaintingID!)
        
        // fetch etme zamanı..
        do{
            let results = try content.fetch(myFetchRequest)
            if !results.isEmpty {   // her ihtimale karşı boş şeyle uğraşmayalım..
                
                for result in (results as! [NSManagedObject]) {
                    
                    if let name = result.value(forKey: "paintingName") as? String {
                        paintingNameTextF.text = name
                    }
                    
                    if let artist = result.value(forKey: "artist") as? String {
                        artistTextF.text = artist
                    }
                    
                    if let year = result.value(forKey: "year") as? Int {
                        madeYearTextF.text = String(year)
                    }
                    
                    if let painting = result.value(forKey: "painting") as? Data {
                        newPainting.image = UIImage(data: painting)
                    }
                    
                }
                
            }
        }catch{
            print("error")
        }
        
        
        
        
        
        
    }
    
    
    @objc func goPhoneLibrary(){
        
        // telefonun fotoğraflar albümünden seçim yapmaya götürüyor beni bu kodlar...
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary // PHPicker kullan diye uyarı veriyor bana !
        picker.allowsEditing = true
        // present ettiğim şey, resim yerine tıklanınca albümlein pop up gibi açılmasını sağlamak oldu.
        present(picker , animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // albümden seçme işi bitince burası çalışacaktır.
        
        if let image = info[.editedImage] as? UIImage { 
            newPainting.image = image
        }
        
        saveButton.isEnabled = true
        
        // foto seçince kapansın pop-up ekranı diye var
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
        // bu ekrana tıklandığında klavyeyi falan kapatacak olan methoddur.
    }
   
    @IBAction func saveClicked(_ sender: Any) {
        
        // AppDelegate class ıma ulaştım.
        let apDelegate = UIApplication.shared.delegate as! AppDelegate
        let content = apDelegate.persistentContainer.viewContext
        
        // core data yı kullanabilmek için 9.satırda import Core Data yamayı unutma
        // newPainting objesi paintings entity min bir objesi. Bu method işimi kolaylaştırıyormuş
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: content)
        
        //Atributes
        newPainting.setValue(paintingNameTextF.text, forKey: "paintingName")
        newPainting.setValue(artistTextF.text, forKey: "artist")
        if let year = Int(madeYearTextF.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue( UUID(), forKey: "id")
        
        // image i 0.5 kalitesinde değiştirerek binaryData data type ında saklamya uygun hale getiriyoruz.
        let storeImage = self.newPainting.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(storeImage, forKey: "painting")
        
        do{
            // taslak objeyi core data ya kaydedtmek.
            try content.save()
            print("succes")
        }catch {
            print("error saving ")
        }
        
        // bu satır kod çalışınca pop-up görüntüsünden geriye dönecekmişiz.
        navigationController?.popViewController(animated: true)
        
        // Bu notificationCen. a verilen isimde bir bildirim gönderiyor ve her VC Bu bildirimi görüp tepki verebiliyor.
        NotificationCenter.default.post(name: NSNotification.Name("new painting arranged"), object: nil)
        
    }
    
}
