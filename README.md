# YelpyClone
[![ezgif-com-video-to-gif-14.gif](https://i.postimg.cc/ZYrH5FW9/ezgif-com-video-to-gif-14.gif)](https://postimg.cc/jCSP8fQK)
An iOS clone of the Yelp app using the Yelp Fusion API.

### Project Status
Completed. Currently migrating concept to SwiftUI framework.

### Screen Shots and Gifs


| [![IMG-1148.png](https://i.postimg.cc/rpF0XZwM/IMG-1148.png)](https://postimg.cc/MnNK1DBF) | [![IMG-1149.png](https://i.postimg.cc/JhGr5fhD/IMG-1149.png)](https://postimg.cc/NyvvgPmB) | [![IMG-1150.png](https://i.postimg.cc/bJZZdGn5/IMG-1150.png)](https://postimg.cc/r0LVPwQG) | [![IMG-1151.png](https://i.postimg.cc/T2mPSvJn/IMG-1151.png)](https://postimg.cc/WtNjFKK4) |
|:------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------:|
|                                      **Home Screen**                                       |                                    **Detail Screen (1)**                                    |                                    **Detail Screen (2)**                                    |                                          **Map**                                           |





| [![ezgif-com-video-to-gif-8.gif](https://i.postimg.cc/ZYrdNd2k/ezgif-com-video-to-gif-8.gif)](https://postimg.cc/4nxykmXw) | [![ezgif-com-video-to-gif-9.gif](https://i.postimg.cc/VLZL0sfQ/ezgif-com-video-to-gif-9.gif)](https://postimg.cc/0bmqLsKc) | [![ezgif-com-video-to-gif-13.gif](https://i.postimg.cc/ZKNVCHzr/ezgif-com-video-to-gif-13.gif)](https://postimg.cc/XpVwPwJJ) |
|:--------------------------------------------------------------------------------------------------------------------------:|:--------------------------------------------------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------------------------------------------------:|
|                                                      ** Home Screen**                                                      |                                                     ** Detail Screen**                                                     |                                                        **Map Screen**                                                        |

### Installation and Setup
1. `download zip file`
2. `open in Xcode`
3. `run on simulator or device`

### Reflection
This was a 3 week long project built during my 2020 summer break. Project goals included using Yelp Fusion API to familiarize myself with querying and parsing data retrieved from REST API's. Additionally, I used this project to practice implementing nauce features, such as share buttons, custom navigation bars, and text messaging.

Originally, I wanted to clone Yelp's restaurant view and map view combo. In the Yelp version, there is a floating view, containing a table view of the restaurants, which slides across a mapview with corresponding pins. This feature was a roadblock for me due to the complexity of writing a custom view that dynamically slides, responds to gestures, and connects to the map view on the same view controller.

At the end of the day, I was able to focus on the details VC where I implemented an impressive custom navigation view bar which exactly mimics the Yelp app. This feature was a big challenge to implement because of the lack of information specific to this niche feature. [The lack of information lead me to write an article about it to help others in the future.](https://medium.com/me/stats/post/3c887160b309) In addition, I learned how to effectively use singletons to share states across VC's and scrollViews to create a pleasant and effective scrolling experience.
