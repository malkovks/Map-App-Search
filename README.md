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
+ Showing distance between pin location and user;
+ Displaying data, which transferred from MapViewController, SearchViewController or FavouriteViewController depending on the case. It include:
   + Main label at the top with name of place;
   + Label with distance;
   + Table view with displaying street name, number of building, administrative area, country, postal code and in second section coordinates;
+ Set direction button. By pressing in open UIMenu to choose type of direction, like Car, Walk, Bicycle and Public Transport;
+ Detail button. It display UIMenu which include:
   + Save location to FavouriteViewController;
   + Share location;
   + Open in Apple Maps;
   + Close window and delete annotation pin on map view.
+ Add to favourite button;
+ Close window button.

<img src="https://user-images.githubusercontent.com/70747233/222846915-de019c2d-bcc4-4148-86f4-547f37878fac.png" width="130"> <img src="https://user-images.githubusercontent.com/70747233/222847005-1220a931-e04b-4521-8165-6fa3ae7bf9a7.png" width="130"> <img src="https://user-images.githubusercontent.com/70747233/222847027-d86c14f2-526e-4ec3-b076-7b66866810fb.png" width="130"> <img src="https://user-images.githubusercontent.com/70747233/222847065-f043bbed-ce63-46ab-b480-9a46ab9fbede.png" width="130"> <img src="https://user-images.githubusercontent.com/70747233/222847090-9d114964-4a3b-4635-94d3-f454fa62d9e8.png" width="130"> <img src="https://user-images.githubusercontent.com/70747233/222847120-0b2cc163-65d9-4320-89c1-97c213c6731a.png" width="130"> <img src="https://user-images.githubusercontent.com/70747233/222847154-648cf6ce-99b1-4257-9e11-88bd5410c488.png" width="130">

4. **FavouriteViewController**. This view display:
+ Table view with displaying main info about saved places. User can choose it and show on map by pressing on cell;
+ It allows user to delete location if it become unnecessary.

<img src="https://user-images.githubusercontent.com/70747233/222848901-28fa3b3c-ff82-44a9-a937-669cc02ad51a.png" width="150"> <img src="https://user-images.githubusercontent.com/70747233/222848931-e4bd443f-7a5e-4845-b3b7-7c6cf32f9356.png" width="150"> <img src="https://user-images.githubusercontent.com/70747233/222848971-c8066bb6-4658-4055-acd5-3fa4b8f6c403.png" width="150">

5. **SetDirectionViewController**. This view is needed for setting up start and finish of route direction. It could start displying by Long Tap Gesture or by clicking on menu cell "Set Direction". It include:
+ First text field which inherit data of user or start location. If user would like to change it, he can click and he goes to SearchViewController to get location for start;
+ Second text field inherit choosen point by gesture location. If it necessary to change, it will goes to SearchViewController to get finish location;
+ "What is it here?" button give action to show what exactly on this point of map which user tap and showing details;
+ Category of possible variations of route. It include 4 types;
+ Table view with favourite places which user can paste in final destination.

<img src="https://user-images.githubusercontent.com/70747233/222855152-7c47b815-8a11-41fc-a2f3-5848af4dd9b3.png" width="200"> <img src="https://user-images.githubusercontent.com/70747233/222855156-59ad7597-d4d3-4300-8829-6b6207f93ebb.png" width="200"> <img src="https://user-images.githubusercontent.com/70747233/222855159-41dc1a88-f104-44e9-8f34-b617ea12d96d.png" width="200"> <img src="https://user-images.githubusercontent.com/70747233/222855166-686d41a1-01f3-4f6f-a7d4-4f645c8073fa.png" width="200"> <img src="https://user-images.githubusercontent.com/70747233/222855609-a7165d1a-8b81-40df-a5f0-88d67c58daec.png" width="200">

6. **ResultDirectionViewController**. Current view display variations of routes, time and distance depending on the route of choosen category.
<img src="https://user-images.githubusercontent.com/70747233/222856475-90308102-8340-4053-97b1-018a9b0556f8.png" width="200">

7. **DeveloperInfoViewController**. This view display short information about develoment, some variations of type to contact with developer.
<img src="https://user-images.githubusercontent.com/70747233/222856834-c71353d1-cfd5-40cf-89f8-8de469430330.png" width="200">

8. **OnboardingViewController**. This view display welcome manual how to use current application and some secondary information.
<img src="https://user-images.githubusercontent.com/70747233/222857029-8bf25a09-736b-495e-a1fa-858664b8d1b9.png" width="200">

9. **WeatherViewController**. Weather app using eponymous API with variations of data such as Current weather, forecast and history of some period and etc.
<img src="https://user-images.githubusercontent.com/70747233/222857245-0d2f0d84-e4ff-437d-aa91-6dfe75703275.png" width="200">

### Frameworks were used:
- **UIKit**;
- **MapKit**;
- **CoreLocationUI**;
- **SPAlert**;
- **FloatingPanel**;
- **UserNotifications**;
- **CoreData**;
- **MessageUI**;

### Personal resolved tasks in App:
* [X] Using UserNotifications for displaying notification with current weather conditions;
* [X] Using custom alert after some actions for simplicity using;
* [X] Using configuration of buttons;
* [X] Using UIMenu as application menu with different actions, objectives and setting edition;
* [X] Using custom Collection View Cells for displaying collections of categories;
* [X] Using custom Table View Cells for displaying custom in SearchViewController;
* [X] Using protocol delegations for reverse data transfer;
* [X] Using UserDefaults for saving system set ups;
* [X] Using CoreData for storing data in two different entities;
* [X] Using MKDirections for start displaying possible routes from first coordinates to second coordinates with different variations of routes;
* [X] Using MKLocalSearch for start searching places by categories and names of the place;
* [X] Using Geocoder for parsing data from location and return data about this place;
* [X] Using Decodable and JSONDecoder for parsing data from API and return in struct.



### Future improvements:
+ [ ] Add configuration to display process of start moving by route direction to final destination;
+ [ ] Integrate Tripadvisor API for detail info about every place and getting collections of images;


### This project is non-commercial product. All rights reserved.
