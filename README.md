# Mp4Autotag #

[Download](https://github.com/muttsnutts/mp4autotag/wiki/download) | [Introduction](#Introduction)

## Introduction ##
Mp4AutoTag is a meta data editor for mp4 file types.  In-other-words, it edits the info you see about the mp4 file in iTunes and Finder.  Mp4AutoTag atempts to locate your mp4 file by file name in [thetvdb.com](http://thetvdb.com) or [themoviedb.org](http://www.themoviedb.org).  It then allows you to save the information to the file.  You can also edit the results, attach different images, rename the file automatically to the proper standard, and/or add a watermark to the image. Images can be pulled from not only [thetvdb.com](http://thetvdb.com) or [themoviedb.org](http://www.themoviedb.org), but also [iTunes Store](http://www.apple.com/itunes/).


## Overview ##

### Download Mp4Autotag ###

You can download Mp4Autotag from the [download page](./download).

### Installing ###

Install by unzipping the downloaded file and copy the Mp4Autotag(.app) file to the Applications directory.

Run Mp4Autotag by browsing to Applications and clicking on Mp4Autotag.

### The Main Window ###

![mp4autotag application empty queue.](http://www.popmedic.com/images/mp4autotag_empty.png)

When you start Mp4Autotag you will see the above Window.  You can drag and drop files into this Window to add mp4's or you can click on the "Add" button, or "File | Add..." to add mp4's to the queue.
![mp4autotag application with Kanon Series in queue.](http://www.popmedic.com/images/mp4autotag_kanon.png)
Once you have mp4's in the queue, you can select them and edit their current tags in the lower panel.  Once edited, you can save the changes by clicking on the "Save" button, or "File | Save".  You could also "Autotag" the mp4 by clicking on the "Autotag" button. If you want to "Autotag" all your mp4's then you can click the "Autotag All" button.  The "Save All" button will save the changes to all the mp4's in your queue.  The "Preferences" button will bring up the preferences panel where you can customize how Mp4Autotag behaves.

### The Autotag Panel ###

![mp4autotag autotag panel.](http://www.popmedic.com/images/mp4autotag_autotagwnd.png)

The Autotag Panel will appear when you do a "Autotag" or "Autotag All".  This panel provides you with a table to see the results for the search on the mp4 file shown in the bottom status line.  Select the result that looks most correct to you and click on the tag button to merge and save the meta-data content to the mp4 file.  If the result you want is not in the table, then try a "Custom Search" by clicking on the "Search" button.  The "Close" button will close the "Autotag" or "Autotag All" session. 

### Preferences ###

#### Cover Art Tab ####

![mp4autotag preferences panel, Cover Art.](http://www.popmedic.com/images/mp4autotag_preferences_ca.png)

* **Use unique TVDB art for each episode.** - When selected show searches will return the image path to an unique image for the episode from [thetvdb.com](http://www.thetvdb.com).
* **Use series art for each episode.** - When selected show searches will return the image path to an image for the series.
* **Add watermark for season/episode.** - When selected image will be watermarked with "S00E00".
* **Use high quality iTunes art.** - When selected the search will return image path to an image from iTunes store. 

#### Other Tab ####

![mp4autotag preferences panel, other.](http://www.popmedic.com/images/mp4autotag_preferences_other.png) 

* **Full automation, no user input.** - This option will make Mp4Autotag search and tag the mp4/'s with the first result returned by the search. See "Fully Automated Autotag" below for more details.
* **Rename file to standard convention.** - This option will rename the mp4 file to a standard convention (for movies - "movie name" ("year"), for shows - "show name" - S"season number"E"episode number" - "episode title").
* **Optimize for network.** - This option will fix the MOOV order so that the movie will play over a network to some less sophisticated browsers and players.  _This option could add up to a minute of processing on saves_.
* **Use "Popmedic" proxy search.** - This option will use a proxy search though [popmedic.com](http://www.popmedic.com/cgi/mp4autotag_cgi.rb).  By using this proxy you will have the most comprehensive and up-to-date search I provide.  You can turn this option off, but the results of a search will not be as accurate.  _See more about the proxy in the Design notes below._ 

### Fully Automated Autotag ###

When this option is selected, if you hit the "Autotag All" button, all the files in the queue will be searched and tagged with the first result returned.  

![mp4autotag autotag automated running panel, other.](http://www.popmedic.com/images/mp4autotag_automated_autotagwnd_running.png)

Once complete, the below panel will be present so you can undo any changes the automated autotag made that are not correct.

![mp4autotag autotag automatedpreferences panel, other.](http://www.popmedic.com/images/mp4autotag_automated_autotagwnd.png) 

* **Left Panel** - This is a table that has the results of the "Fully Automated Autotag."  Select rows in this table to see the changed properties.  If you do not like the changes, click the "Undo" button in the "Right Panel."
* **Right Panel** - This is a table showing the changes in the selected file of the "Left Panel."  Properties changed will be highlighted in red.  If you don't like the changes, click the "Undo" button. 
* **Undo Button** - This button will "Undo" the changes made to the file selected in the "Left Panel."


## Dev Team ##

* Master Coder - popmedic  
* Sidekick - muttsnutts

