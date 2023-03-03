//
//  SearchHistoryStack.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
/*
 Thic entity created for storing data about choosen places after searching in Search VC.
 */

import UIKit
import CoreData
import SPAlert

class SearchHistoryStack {
    static let instance = SearchHistoryStack()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var historyVault = [SearchHistory]()
    
    func loadHistoryData(){
        do {
            historyVault = try context.fetch(SearchHistory.fetchRequest())
        } catch {
            SPAlert.present(message: "Ошибка выгрузки", haptic: .error)
        }
    }
    
    func saveHistoryDataElement(name: String, lan: Double, lon: Double){
        let vault = SearchHistory(context: context)
        vault.nameCategory = name
        vault.langitude = lan
        vault.longitude = lon
        do {
            try context.save()
            loadHistoryData()
        } catch {
            SPAlert.present(message: "Ошибка добавления в историю", haptic: .error)
        }
    }
    
    func deleteLastElement(data: SearchHistory){
        context.delete(data)
        do {
            try context.save()
        } catch {
            SPAlert.present(title: "Ошибка удаления", preset: .error)
        }
    }
    
    func deleteHistoryData(data: [SearchHistory]){
        let _ = data.map { context.delete($0) }
        do {
            try context.save()
            SPAlert.present(message: "Очищено", haptic: .success)
            loadHistoryData()
        } catch {
            SPAlert.present(message: "Ошибка удаления", haptic: .error)
        }
    }
}
