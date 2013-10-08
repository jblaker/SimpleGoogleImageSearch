# Simple Google Image Search

This simple iOS application lets you do a Google Image search where the results are displayed in a grid layout. Scrolling down through the view will continue to load more images. 

Search history is retained so you can go back view previous searches.

![image](http://dev.blakerdesign.com/misc/img/image-search.png)

## Dependencies
* [AFNetworking](https://github.com/AFNetworking/AFNetworking) - Used for API requests
* [MBProgressHUD](https://github.com/jdg/MBProgressHUD) - Used for indicating loading
* [SDWebImage](https://github.com/rs/SDWebImage) - Used for image caching
* [PSTCollectionView](https://github.com/steipete/PSTCollectionView) - Used for iOS 5 UICollectionView compatability
* [OCMock](https://github.com/erikdoe/ocmock) - Used for mocking objects in unit tests

### Dependency Management
All dependencies are managed by [CocoaPods](http://cocoapods.org). If you already have CocoaPods installed simply run:

	pod install

Then you should be able to open the **Google Image Search.xcworkspace** file and run the project.