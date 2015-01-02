CVCalendar
==========

A custom visual calendar for iOS 8 written in Swift.

Screenshots
==========

![alt tag](https://raw.githubusercontent.com/Mozharovsky/CVCalendar/master/Screenshots/Pic1.png) ![alt tag](https://raw.githubusercontent.com/Mozharovsky/CVCalendar/master/Screenshots/Demo.gif)

Arcitecture
==========

This calendar is designed according to all object oriented patterns. There are a few types of objects where a particular instance does its specific stuff. I've tried to separate Views from all the stuff it shouldn't do itself (e.g. calculations, date management etc). 

Types of Views:

* CVCalendarView — Control properties main container, manages practically all the init stuff. 
* CVCalendarContentView — Content container, defined as a ScrollView, manages scrolling & loading.
* CVCalendarMonthView — Month container, takes responsibility for building WeekViews. 
* CVCalendarWeekView — Week container, constructs DayViews. 
* CVCalendarDayView — Fundamental unit, represents a simple day view. 
* CVCalendarCirlceView — Auxiliary view for marking. 
* CVCalendarMenuView — Menu container with weekdays' symbols. 

First of all, we create an instance of CVCalendarView that creates CVCalendarContentView's one for containing all MonthViews. The CVCalendarContentView object creates a canvas for holding up to 3 CVCalendarMonthView instances. Only one MonthView can be displayed at the time so 2 other objects remain outside (on the left and right sides of the presented instance). When it's time for scrolling we figure out the direction and make a scroll either to the left or right MonthView, replacing it to the middle cell and then the empty cell is filled with a new MonthView. 

Once an object of CVCalendarMonthView is created it initializes itself and creates CVCalendarWeekView instances depending on their count (which is calculated by CVCalendarManager). Each WeekView creates a set of CVCalendarDayViews. All the calculations (basically, it's about frames) are proceeded by specific (util) objects according to the user preferences (through delegates). 

DayViews create CVCircleViews when they're highlighted as well as they remove circles on unhighlighting. CircleView is also used to represent a dot marker for marking some event. CVCalendarMenuView containts symbols of weekdays (it supports different languages).

Types of Utils: 

* CVCalendarRenderer — Makes all frames' calculations. 
* CVCalendarManager — Analyzes the given date. 
* CVCalendarViewAppearance — Contains and manages all appearance delegate's input. 
* CVCalendarDayViewCoordinator — Handles touch events on DayViews. 
* CVCalendarViewAnimator — Manages selection animations. 
 
Here everything is pretty obvious. CVCalendarViewAppearance represents an object that conforms to the corresponding protocol and as a result manages its stuff (either takes input from a user or gives a default value). CVCalendarViewAnimator also can be replaced with custom animations if it's necessary. 

Types of Protocols: 

* CVCalendarViewDelegate — Takes fundamental data.  
* CVCalendarViewAppearanceDelegate — Defines methods for taking appearance stuff. 
* CVCalendarViewAnimatorDelegate — The same for animation. 

And there is one more type that represents a custom date:

* CVDate


Usage
==========


