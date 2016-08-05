# Project 1 - *Flicks*

**Flicks** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **17.7** hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] User can view a list of movies currently playing in theaters. Poster images load asynchronously.
- [X] User can view movie details by tapping on a cell.
- [X] User sees loading state while waiting for the API.
- [X] User sees an error message when there is a network error.
- [X] User can pull to refresh the movie list.
- [X] Add a tab bar for **Now Playing** and **Top Rated** movies.
- [x] Implement segmented control to switch between list view and grid view.

The following **optional** features are implemented:

- [X] Add a search bar.
- [X] All images fade in.
- [X] For the large poster, load the low-res image first, switch to high-res when complete.
- [X] Customize the highlight and selection effect of the cell.
- [X] Customize the navigation bar.
- [X] Tapping on a movie poster image shows the movie poster as full screen and zoomable.
- [X] User can tap on a button to play the movie trailer.

The following **additional** features are implemented:

- [X] Customize Tab Bar
- [X] Custom segue to movie poster

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/link/to/your/gif/file.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

- When is variable shadowing discouraged?

- Not sure best way to handle hiding keyboard for search bar, currently doing this:

            if (searchText == "") {
              filteredMovies = movies

              // TODO: janky
              searchBar.performSelector(#selector(UIResponder.resignFirstResponder), withObject: nil, afterDelay: 0.1)
            }

- The search bar UX isn't so good. I need a *Cancel* button.

- Pinch-zoom isn't smooth (only zooms when I let go)

## License

    Copyright 2016 Gil Birman

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.