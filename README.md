### Vimeo Mobile & TV
#### iOS Coding Exercise

BogusCode is an iOS app that fetches and displays the first page of videos in the [Vimeo Staff Picks channel](https://developer.vimeo.com/api/endpoints). However, the codebase and user experience are suboptimal to say the least.  

You’ve inherited BogusCode and your task is to elevate it to your own standard of quality. Correct all of the issues you see, refactor as you see fit, and make BogusCode clean, clear, performant and scalable.  

* A bug-free app that displays the Staff Picks list
* Architectural clarity, architecture that can scale
* Clean, clear, and communicative UI

Adding new features and functionality is not necessary. But if you're interested in taking on some extra credit tasks here are a few ideas: 

* JSON response caching
* Image caching
* Pagination
* And anything else that comes to mind...

With your returned submission **please modify the `README`** to contain a brief summary of the issues you identified, the changes you made to correct them, and rationale behind those changes.

Feel free to send us any questions that might arise along the way. And good luck!

*Note: You can obtain an OAuth token [here](https://developer.vimeo.com/apps).*  
*Note: The use of third party libraries is not allowed. Submissions that leverage third party code will be disqualified.*

Changes I've Made
 - Spelling error in navigation title
 - Used NSURLSession to load api requests (Included caching)
 - Created a custom tableview cell to from a Xib file to display videos
     - Can see thumbnail, video duration, video title, video author, author profile image, video plays, video likes, how long ago video was uploaded, and video comments
    - Created a Video struct to hold all the data for each tableview cell (includes an init to parse json data)
- Added pagination so that new videos from next pages are only requested when user scrolls to the end of the current page in the tableview
-  Added error handling of basic HTTP error responses and NSURLSession errors (shows alert when error occurs)
  - Added a loading indicator when new pages and app is loading to communicate app state to user
 -Added function to watch video in web browser when you click on a tableview cell
 - Added image cacheing using NSCache and indexing via URL string
 
