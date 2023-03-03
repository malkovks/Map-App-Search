# Map Application
Little introduction. This application based on **Apple's Maps**, using same frameworks and performs main functionallity(except for the technical limitations of kit). Application using **Russian localization**. It mean all UI texts and alerts using russian text.
### Stack of development:
1. UIKit;
2. Swift 3 and newer;
3. iOS 11+;
4. MVC pattern of architecture;
5. CoreData for storing data;
6. UI displaying only codable no using Storyboard/AutoLayouts;
7. CocoaPods.

### This app based on:
- Apple's Frameworks [MapKit](https://developer.apple.com/documentation/mapkit/);
- Framework "SPAlert" by [ivanvorobei](https://github.com/ivanvorobei/SPAlert);
- Framework "Floating Panel" by [scenee](https://github.com/scenee/FloatingPanel);
- Weather API [Weather API](https://www.weatherapi.com).

### Application intended for:
- Searching place's from caffeine to countries; 
- Checking for weather climate in user's region; 
- Setting up direction route, display distance and time of route;
- Adding places to favourites category.

## **Main Objectives:**
1. **Map View Controller**. This view include:
+ segue's button to Search View Controller as "Search image";
+ segue's button to Favourite View Controller as "Bookmark image"; 
+ segue's button to Weather View Controller with displaying current temperature of user's location and condition;
+ Location button which display user point and center zoom on map;
+ Stepper for zooming map camera;
+ Clear map button for removing all annotations and routes direction;
+ Detail button based on UIMenu and displaying cell with:
    + segue to Information about app;
    + segue to Favourite View Controller;
    + segue to Weather View Controller;
    + showing pins of all favourite places on map view;
    + adding user's location to Favourite View Controller;
    + setting up direction route;
    + sharing user's location with UIActivityViewController;
    + adding or removing car trafic;
    + changing map type on: 
       + satellite
       + hybrid
       + standart
    + clear map from annotations and routes.
    
<img src="https://user-images.githubusercontent.com/70747233/222773671-2137976a-9443-4554-9d28-4b8681682ab8.png" width="150"> <img src="https://user-images.githubusercontent.com/70747233/222776008-9256697f-c7db-4d08-bd32-e93f65bb0e4d.png" width="150"> <img src="https://user-images.githubusercontent.com/70747233/222776022-229547b2-0709-4551-a2ab-429de42e664a.png" width="150"> <img src="https://user-images.githubusercontent.com/70747233/222776031-a9c0c217-2591-4533-bb64-6613a582543c.png" width="150"> <img src="https://user-images.githubusercontent.com/70747233/222776049-30f3895c-07d0-41b9-9547-ee4de9cee8bb.png" width="150">
2. **Search View Controller**. This view have:
+ Collection view with custom cells which displaying some types of the most useful categories for fast searching;
+ Table view. It display search result in first section. In second section it display history of searching;
+ Switch controller for changing section:
   + First section include collection view and if user start to print some text collection become hidden and table ceases to be hidden;
   + Second section include history of search. It use table view with basic displaying name of place, short address. Also it has clear button to delete all data from history(if it necessary for user).  
+ After finding something that user search for, he can choose that cell and it will display pin on map and open DetailViewController.
   
<img src="https://user-images.githubusercontent.com/70747233/222830622-59408756-7661-490a-bbc4-dd497e10e26b.png" width="150"> <img src="https://user-images.githubusercontent.com/70747233/222830642-769efb00-f056-4d07-b0bd-20a8e629bfe0.png" width="150"> <img src="https://user-images.githubusercontent.com/70747233/222830652-2d501107-0d29-4e62-83c7-e2f6d5de557f.png" width="150"> <img src="https://user-images.githubusercontent.com/70747233/222830662-94783712-6891-4dad-a213-550261a8706b.png" width="150"> <img src="https://user-images.githubusercontent.com/70747233/222830668-353eb4ec-c4c2-400e-9da0-6f87ebeadd73.png" width="150">
3. **DetailViewController**. This view intented for:
+ Displaying data, which transferred from MapViewController, SearchViewController or FavouriteViewController depending on the case;
+ 



### This project is non-commercial product. All rights reserved.
