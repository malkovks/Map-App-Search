# Map Application
## This App now in intensive development and did not ended. Screenshots will be sooner
Application for searching places like restaurants, markets, museums, user's address and etc.
## **This application was based by Apple API [MapKit](https://developer.apple.com/documentation/mapkit/).**
All data placemarks taken from MapKit API and decode it to neccessary information. Also search working through this API. This API have limited count of requests by user. 

# Main idea of this app is to do similar application like Apple's Map Application.

### Important reminder. Current app using only Xcode based frameworks and kits such as UIKit, CoreData, MapKit, CoreLocation and etc.

## **Main Objectives:**
1. Main page. This page display search bar by search controller. If user print something, it will show the results on separate table view. API searching result using user location to show nearest places. 
2. Buttons on main page. User location button show location by press. Detail button show separate floating panel, where is located full information about choosen places by user. Clear button neccessary for clear map from pins, requests, directions.
3. Favourite Page. This page include table view where user save his own places. All data saving in Core Data and loading similarly. By pressing specific one cell app segue to Full Information View with full information about this location.
4. Full Information page. This page using framework [Floating Panel](https://github.com/scenee/FloatingPanel). It include labels and tables for displaying info about choosen place and buttons for add to Favourite Page and set direction from user to this place.

### **Improvements for the future:**
- Made this app autonomical from Internet;
- Customize visual UI;
- Add types of setting directions
- Use separate API for getting full information;
