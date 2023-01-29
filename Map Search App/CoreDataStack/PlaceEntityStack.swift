//
//  PlaceEntityStack.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
//

import UIKit
import CoreData
import SPAlert

public class PlaceEntityStack {
    
    static let instance = PlaceEntityStack()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var vaultData = [PlaceEntity]()
    
    
    
    func loadData(){
        do {
            vaultData = try context.fetch(PlaceEntity.fetchRequest())
        } catch {
            SPAlert.present(title: "Error of CoreData.\nCheck it", preset: .error)
        }
    }
    
    func saveData(lat: Double,lon: Double, date: String?){
        let place = PlaceEntity(context: context)
        place.date = date
        place.latitude = lat
        place.longitude = lon
        do {
            try context.save()
            SPAlert.present(title: "Success",message: "This place was added to Favourite Page", preset: .heart, haptic: .success)
        } catch {
            SPAlert.present(title: "Error of CoreData.\nCheck it", preset: .error)
            
            
        }
    }
    
    func deleteData(data: PlaceEntity){
        context.delete(data)
        do {
            try context.save()
            SPAlert.present(title: "Deleted", preset: .custom(UIImage(systemName: "trash")!))
        } catch {
            SPAlert.present(title: "Error of CoreData.\nCheck it", preset: .error)
        }
    }

}
