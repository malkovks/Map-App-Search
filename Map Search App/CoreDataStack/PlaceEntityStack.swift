//
//  PlaceEntityStack.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
/*
 class created for saving,loading and deleting for favourite places. This entity store and process data for Favourite places
 */

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
            SPAlert.present(title: "Ошибка выгрузки\nПопробуйте позже", preset: .error)
        }
    }
    
    func saveData(lat: Double,lon: Double, date: String?,name place: String){
        let placeValue = PlaceEntity(context: context)
        placeValue.date = date
        placeValue.latitude = lat
        placeValue.longitude = lon
        placeValue.place = place
        do {
            try context.save()
            SPAlert.present(title: "Успешно!",message: "Это место добавлено в избранное", preset: .heart, haptic: .success)
        } catch {
            SPAlert.present(title: "Ошибка сохранения\nПопробуйте позже", preset: .error)
            
            
        }
    }
    
    func deleteData(data: PlaceEntity){
        context.delete(data)
        do {
            try context.save()
            SPAlert.present(title: "Удалено!", preset: .custom(UIImage(systemName: "trash")!))
        } catch {
            SPAlert.present(title: "Ошибка удаления\nПопробуйте позже", preset: .error)
        }
    }

}
