# Change Log

## [1.5.0](https://github.com/CVCalendar/CVCalendar/tree/1.5.0) (2017-03-24)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.4.1...1.5.0)

**Implemented enhancements:**

- Select Date Range [\#12](https://github.com/CVCalendar/CVCalendar/issues/12)

**Fixed bugs:**

- Year is stuck on current year. [\#403](https://github.com/CVCalendar/CVCalendar/issues/403)
- Month with 6 rows not always showing days in the 6th row [\#396](https://github.com/CVCalendar/CVCalendar/issues/396)
- Unable to use CVCalendar in asynchronous unit tests  [\#380](https://github.com/CVCalendar/CVCalendar/issues/380)

**Closed issues:**

- Project doesn't compile on master branch [\#433](https://github.com/CVCalendar/CVCalendar/issues/433)
- didShowNextMonthView & didShowPreviousMonthView [\#432](https://github.com/CVCalendar/CVCalendar/issues/432)
- How do I jump to the next year? [\#431](https://github.com/CVCalendar/CVCalendar/issues/431)
- Manual installation [\#422](https://github.com/CVCalendar/CVCalendar/issues/422)
- can i multi select days with this library. I want to select and colour multiple dates at once [\#421](https://github.com/CVCalendar/CVCalendar/issues/421)
- Select dayOut and change month [\#418](https://github.com/CVCalendar/CVCalendar/issues/418)
- FUNCTION SUPPLEMENTARYVIEW [\#417](https://github.com/CVCalendar/CVCalendar/issues/417)
- How do I set start and end date range in the Calendar?  [\#416](https://github.com/CVCalendar/CVCalendar/issues/416)
- Question: Is there a way to change between month view and week view if the device is rotated [\#415](https://github.com/CVCalendar/CVCalendar/issues/415)
- How to enable selection for current day [\#413](https://github.com/CVCalendar/CVCalendar/issues/413)
- How do i Jump to next  or previous Year? [\#410](https://github.com/CVCalendar/CVCalendar/issues/410)
- Weekview not showing [\#409](https://github.com/CVCalendar/CVCalendar/issues/409)
- supplementaryView shown on wrong day [\#408](https://github.com/CVCalendar/CVCalendar/issues/408)
- RTL orientation [\#406](https://github.com/CVCalendar/CVCalendar/issues/406)
- CVCalendar 1.4.1 not in Cocoapods old repository [\#405](https://github.com/CVCalendar/CVCalendar/issues/405)
- Month View Frame change  [\#402](https://github.com/CVCalendar/CVCalendar/issues/402)
- How do I add events to the calendar? [\#401](https://github.com/CVCalendar/CVCalendar/issues/401)
- CVCalendar rendering all views on Sunday. [\#398](https://github.com/CVCalendar/CVCalendar/issues/398)
- Distance between monthLabel and weekday symbols [\#397](https://github.com/CVCalendar/CVCalendar/issues/397)
- Month with 6 Rows Not always showing 6th row. [\#395](https://github.com/CVCalendar/CVCalendar/issues/395)
- How Can I scroll previous and following calendar view using custom button tap in swift? [\#394](https://github.com/CVCalendar/CVCalendar/issues/394)
- how to move to current month view? [\#393](https://github.com/CVCalendar/CVCalendar/issues/393)
- CVCalendar Demo Crash in presentedDateUpdated\(\) when unwrapping optional [\#391](https://github.com/CVCalendar/CVCalendar/issues/391)
- CVCalendarViewAppearance.swift [\#388](https://github.com/CVCalendar/CVCalendar/issues/388)
- Using CVCalendar with Swift 2.2 [\#366](https://github.com/CVCalendar/CVCalendar/issues/366)
- There is no way to remove preliminary view [\#364](https://github.com/CVCalendar/CVCalendar/issues/364)
- Update project short description [\#362](https://github.com/CVCalendar/CVCalendar/issues/362)
- Incorrect date on dotMarker\(shouldShowOnDayView dayView: DayView\) -\> Bool  [\#360](https://github.com/CVCalendar/CVCalendar/issues/360)
- EXPLANATION "SUPPLEMENTARY VIEW" [\#352](https://github.com/CVCalendar/CVCalendar/issues/352)
- Get start and end date for Month and week respectively for both mode  [\#317](https://github.com/CVCalendar/CVCalendar/issues/317)
- Set custom date [\#251](https://github.com/CVCalendar/CVCalendar/issues/251)
- Add Ability to switch between Calendars & Locales [\#197](https://github.com/CVCalendar/CVCalendar/issues/197)
- didShowNextMonthView and didShowPreviousMonthView not being called [\#188](https://github.com/CVCalendar/CVCalendar/issues/188)
- AutoLayout issue [\#159](https://github.com/CVCalendar/CVCalendar/issues/159)

**Merged pull requests:**

- Fix \#433 [\#435](https://github.com/CVCalendar/CVCalendar/pull/435) ([elsesiy](https://github.com/elsesiy))
- fix issue where 'out' dates still selectable when should be disabled [\#424](https://github.com/CVCalendar/CVCalendar/pull/424) ([esetnik](https://github.com/esetnik))
- Set proper day view text color during the initialization for current date; [\#414](https://github.com/CVCalendar/CVCalendar/pull/414) ([Antondomashnev](https://github.com/Antondomashnev))
- SupplementaryView-Demo-Standardization [\#412](https://github.com/CVCalendar/CVCalendar/pull/412) ([DannyJi](https://github.com/DannyJi))
- Fix demo’s drawing of supplementary view.  [\#411](https://github.com/CVCalendar/CVCalendar/pull/411) ([justinctlam](https://github.com/justinctlam))
- Make sure to construct the calendar before anything uses it. Make sure to always use the calendar from the delegate instead of the current calendar. [\#404](https://github.com/CVCalendar/CVCalendar/pull/404) ([justinctlam](https://github.com/justinctlam))
- Weakify the animation callbacks; [\#400](https://github.com/CVCalendar/CVCalendar/pull/400) ([Antondomashnev](https://github.com/Antondomashnev))
- Fixed crash in demo [\#392](https://github.com/CVCalendar/CVCalendar/pull/392) ([justinctlam](https://github.com/justinctlam))
- Use Calendar.current as a default for CVDate; [\#390](https://github.com/CVCalendar/CVCalendar/pull/390) ([Antondomashnev](https://github.com/Antondomashnev))
- Change from nil to a new value is a update [\#389](https://github.com/CVCalendar/CVCalendar/pull/389) ([beset](https://github.com/beset))

## [1.4.1](https://github.com/CVCalendar/CVCalendar/tree/1.4.1) (2016-11-27)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.4.0...1.4.1)

**Implemented enhancements:**

- now working with orientation changes. [\#102](https://github.com/CVCalendar/CVCalendar/issues/102)

**Fixed bugs:**

- now working with orientation changes. [\#102](https://github.com/CVCalendar/CVCalendar/issues/102)

**Closed issues:**

- appearance?.dayLabelWeekdayOutTextColor : myColor\[dotIndex\] - fatal error: Index out of range [\#383](https://github.com/CVCalendar/CVCalendar/issues/383)
- .toggleViewWithDate\(date: NSDate\) Method not working if shouldAutoSelectDayOnMonthChange is set to false [\#382](https://github.com/CVCalendar/CVCalendar/issues/382)
- Jump to today button [\#378](https://github.com/CVCalendar/CVCalendar/issues/378)
- Set Gregorian Calendar event thought user choose Buddhist... [\#377](https://github.com/CVCalendar/CVCalendar/issues/377)
- Implement date range selection [\#374](https://github.com/CVCalendar/CVCalendar/issues/374)
- TimeZone-Free selected date?? [\#372](https://github.com/CVCalendar/CVCalendar/issues/372)
- Can't set shouldShowWeekdaysOut [\#368](https://github.com/CVCalendar/CVCalendar/issues/368)
- didSelectDayView not called on launch [\#367](https://github.com/CVCalendar/CVCalendar/issues/367)
- Menu labels overlap [\#361](https://github.com/CVCalendar/CVCalendar/issues/361)
- Updating to iOS 10 bugs - suggesions? [\#359](https://github.com/CVCalendar/CVCalendar/issues/359)
- swift 2.3 support [\#357](https://github.com/CVCalendar/CVCalendar/issues/357)
- Place date at the top of the cell [\#356](https://github.com/CVCalendar/CVCalendar/issues/356)
- in swift 3.0 error [\#355](https://github.com/CVCalendar/CVCalendar/issues/355)
- Edit the look of the date cells. [\#354](https://github.com/CVCalendar/CVCalendar/issues/354)
-  MORE THAT A PROBLEM IS A QUESTION ON THE PROCEDURE CVCALENDAR [\#353](https://github.com/CVCalendar/CVCalendar/issues/353)
- Error in swift 3.0 [\#350](https://github.com/CVCalendar/CVCalendar/issues/350)
- Swift 2.3 [\#349](https://github.com/CVCalendar/CVCalendar/issues/349)
- 1.3.0 does not work [\#348](https://github.com/CVCalendar/CVCalendar/issues/348)
- Error when using CVCalendar library with Xcode 8 bet and Swift 3.0 [\#314](https://github.com/CVCalendar/CVCalendar/issues/314)

**Merged pull requests:**

- When the newly set presentedDate equals to the old presentedDate, presentedDate don’t update [\#387](https://github.com/CVCalendar/CVCalendar/pull/387) ([beset](https://github.com/beset))
- Should allow toggleViewWithDate even if there’s no selected date. Fix SUN menu text color so it is visible. [\#386](https://github.com/CVCalendar/CVCalendar/pull/386) ([justinctlam](https://github.com/justinctlam))
- Fix for rotation view [\#384](https://github.com/CVCalendar/CVCalendar/pull/384) ([justinctlam](https://github.com/justinctlam))
- Replace constant toggling animation duration with the toggleDateAnimationDuration; [\#379](https://github.com/CVCalendar/CVCalendar/pull/379) ([Antondomashnev](https://github.com/Antondomashnev))
- Store preliminaryView in dayView and remove it if not visible anymore; [\#365](https://github.com/CVCalendar/CVCalendar/pull/365) ([Antondomashnev](https://github.com/Antondomashnev))
- Remove unnecessary get keyword [\#363](https://github.com/CVCalendar/CVCalendar/pull/363) ([shoheiyokoyama](https://github.com/shoheiyokoyama))
- Fix supplementary and preliminary views setup [\#358](https://github.com/CVCalendar/CVCalendar/pull/358) ([ludoded](https://github.com/ludoded))

## [1.4.0](https://github.com/CVCalendar/CVCalendar/tree/1.4.0) (2016-09-14)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.3.1...1.4.0)

**Closed issues:**

- Change the month and the app goes in crash!!! [\#337](https://github.com/CVCalendar/CVCalendar/issues/337)

## [1.3.1](https://github.com/CVCalendar/CVCalendar/tree/1.3.1) (2016-09-14)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.3.0...1.3.1)

**Closed issues:**

- How to change Year? [\#345](https://github.com/CVCalendar/CVCalendar/issues/345)
- Highlight of the today is wrong [\#343](https://github.com/CVCalendar/CVCalendar/issues/343)
- Calendar without dots and disabled days. [\#342](https://github.com/CVCalendar/CVCalendar/issues/342)
- Programmatically Reloading the Calendar [\#340](https://github.com/CVCalendar/CVCalendar/issues/340)
- Problem with the last update!!! [\#336](https://github.com/CVCalendar/CVCalendar/issues/336)
- dotMarker Show wrong date match , How to fix? [\#335](https://github.com/CVCalendar/CVCalendar/issues/335)
- Text Label Color for Unselected Dates [\#334](https://github.com/CVCalendar/CVCalendar/issues/334)
- Nib Files and @IBDesignable [\#329](https://github.com/CVCalendar/CVCalendar/issues/329)
- How to add events to month view & reload the monthview ? [\#328](https://github.com/CVCalendar/CVCalendar/issues/328)
- how can we navigate  different date now it is loading currentdate.  [\#326](https://github.com/CVCalendar/CVCalendar/issues/326)
- New version on Cocoapods [\#323](https://github.com/CVCalendar/CVCalendar/issues/323)
- How can i change Scroll From Horizontal to Vertical when change month? [\#319](https://github.com/CVCalendar/CVCalendar/issues/319)
- How to init a date in one specific month when I calendar show up? [\#318](https://github.com/CVCalendar/CVCalendar/issues/318)
- display current and following months only in the calendar view [\#312](https://github.com/CVCalendar/CVCalendar/issues/312)
- Disable or Change Past Days text color or selection background color [\#311](https://github.com/CVCalendar/CVCalendar/issues/311)
- How to avoid selected day default circle being overlapped by supplementary view? [\#302](https://github.com/CVCalendar/CVCalendar/issues/302)
- Cant import CVCalendar [\#296](https://github.com/CVCalendar/CVCalendar/issues/296)
- I want this feature: 1. User can select multiple dates 2. On long tapping a date it will ask for selecting the date range to get selected. [\#295](https://github.com/CVCalendar/CVCalendar/issues/295)
- I want to select multiple dates on an urgent basis. Please help me. [\#294](https://github.com/CVCalendar/CVCalendar/issues/294)
- issue while updating on swift 2.2 [\#293](https://github.com/CVCalendar/CVCalendar/issues/293)
- Turn off swipe functionality? [\#277](https://github.com/CVCalendar/CVCalendar/issues/277)
- Slow updating when change mode [\#225](https://github.com/CVCalendar/CVCalendar/issues/225)
- jalali calendar [\#217](https://github.com/CVCalendar/CVCalendar/issues/217)

**Merged pull requests:**

- Issue \#337, "Change the month and the app goes in crash!" [\#346](https://github.com/CVCalendar/CVCalendar/pull/346) ([nikolay-dementiev](https://github.com/nikolay-dementiev))
- Swift 3 [\#339](https://github.com/CVCalendar/CVCalendar/pull/339) ([Antoine4011](https://github.com/Antoine4011))
- Customize duration of date selection animation [\#338](https://github.com/CVCalendar/CVCalendar/pull/338) ([ozgur](https://github.com/ozgur))

## [1.3.0](https://github.com/CVCalendar/CVCalendar/tree/1.3.0) (2016-09-02)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.2.9...1.3.0)

**Closed issues:**

- Menu view sends wrong weekdays to its delegate methods [\#333](https://github.com/CVCalendar/CVCalendar/issues/333)
- Dotmarker are appearing on the next date from the date I applied. [\#327](https://github.com/CVCalendar/CVCalendar/issues/327)
- When month is changed thru swiping in either direction, I want to handle certain action. [\#325](https://github.com/CVCalendar/CVCalendar/issues/325)
- Make selected Dayview's highlighted color shape square instead of rounded [\#321](https://github.com/CVCalendar/CVCalendar/issues/321)
- Reload calendar data [\#320](https://github.com/CVCalendar/CVCalendar/issues/320)
- Long press date for popup modal [\#316](https://github.com/CVCalendar/CVCalendar/issues/316)
- I need to implement calendar view like Activity app with activity ring under every day.  [\#315](https://github.com/CVCalendar/CVCalendar/issues/315)
- Past days greyed out? [\#309](https://github.com/CVCalendar/CVCalendar/issues/309)
- How to mark Dots on desire date? [\#306](https://github.com/CVCalendar/CVCalendar/issues/306)
- How can i grey out custom dates in a fast and efficient way, it would be nice to have this feature, i added a delegate to check the dayView for days and grey out those days, I also would like to have no user interaction on the grey out dates [\#304](https://github.com/CVCalendar/CVCalendar/issues/304)
- Undefined symbols for architecture arm64: [\#303](https://github.com/CVCalendar/CVCalendar/issues/303)
- I tried to install using cocoapod like in the documentation, but it gets stuck and just stuck. Is there any new way to add this library??  [\#301](https://github.com/CVCalendar/CVCalendar/issues/301)
- Blue circle too great in landscape mode!!! [\#300](https://github.com/CVCalendar/CVCalendar/issues/300)
- Is it possible to customise CVCalendarView? [\#299](https://github.com/CVCalendar/CVCalendar/issues/299)
- Initilaze date [\#297](https://github.com/CVCalendar/CVCalendar/issues/297)
- Content Alignment? [\#292](https://github.com/CVCalendar/CVCalendar/issues/292)
- DotMarker Color [\#291](https://github.com/CVCalendar/CVCalendar/issues/291)
- How to set current day label unselected color? [\#290](https://github.com/CVCalendar/CVCalendar/issues/290)
- Possibility to set the selected date [\#283](https://github.com/CVCalendar/CVCalendar/issues/283)
- CVCalendarView only appearing on iPhone Plus [\#281](https://github.com/CVCalendar/CVCalendar/issues/281)
- How about 'day view' and 'week view' ? [\#276](https://github.com/CVCalendar/CVCalendar/issues/276)
- why CVCalendarContentViewController is a subclass of UIViewController? [\#275](https://github.com/CVCalendar/CVCalendar/issues/275)
- how can we remove dots and add lines on that day... instead of dots want to add Lines..  [\#271](https://github.com/CVCalendar/CVCalendar/issues/271)
- Is their any way to view default look as weekview.. Not the monthview [\#265](https://github.com/CVCalendar/CVCalendar/issues/265)
- Vertical month scrolling   [\#260](https://github.com/CVCalendar/CVCalendar/issues/260)
- CVCalendarView disappears [\#258](https://github.com/CVCalendar/CVCalendar/issues/258)
- New Install can not find CVCalendarView [\#257](https://github.com/CVCalendar/CVCalendar/issues/257)
- Is their any way to view default look  as weekview.. Not the monthview [\#256](https://github.com/CVCalendar/CVCalendar/issues/256)
- how to hide or disable days before today  [\#255](https://github.com/CVCalendar/CVCalendar/issues/255)
- memory leakage. [\#252](https://github.com/CVCalendar/CVCalendar/issues/252)
- Need reload function [\#249](https://github.com/CVCalendar/CVCalendar/issues/249)
- range selection [\#248](https://github.com/CVCalendar/CVCalendar/issues/248)
- Installation problem [\#245](https://github.com/CVCalendar/CVCalendar/issues/245)
- Change colour of menu labels [\#242](https://github.com/CVCalendar/CVCalendar/issues/242)
- Nepali Calendar [\#239](https://github.com/CVCalendar/CVCalendar/issues/239)
- unable to get the right NSDate back [\#236](https://github.com/CVCalendar/CVCalendar/issues/236)
- Changelog has not been updated in 9 months [\#235](https://github.com/CVCalendar/CVCalendar/issues/235)
- How do i reload the calendar view? [\#234](https://github.com/CVCalendar/CVCalendar/issues/234)
- Add different color of event [\#224](https://github.com/CVCalendar/CVCalendar/issues/224)
- Carthage [\#204](https://github.com/CVCalendar/CVCalendar/issues/204)
- Warnings in Library [\#169](https://github.com/CVCalendar/CVCalendar/issues/169)
- sir help me please [\#157](https://github.com/CVCalendar/CVCalendar/issues/157)

**Merged pull requests:**

- Fixed populating incorrect weekdays [\#332](https://github.com/CVCalendar/CVCalendar/pull/332) ([ozgur](https://github.com/ozgur))
- Updating Top Marker Color [\#331](https://github.com/CVCalendar/CVCalendar/pull/331) ([ozgur](https://github.com/ozgur))
- Preventing selections. and the DayView can be configured by weekdays [\#322](https://github.com/CVCalendar/CVCalendar/pull/322) ([wanbok](https://github.com/wanbok))
- Merge Request [\#310](https://github.com/CVCalendar/CVCalendar/pull/310) ([jobinsjohn](https://github.com/jobinsjohn))
- Fixed colouring for more than one dot marker after unhighlighting day [\#307](https://github.com/CVCalendar/CVCalendar/pull/307) ([GentleTroll](https://github.com/GentleTroll))
- Adding BackGround colour for day of weeks in MenuView [\#305](https://github.com/CVCalendar/CVCalendar/pull/305) ([shallad](https://github.com/shallad))
- Minor Readme.md edit [\#284](https://github.com/CVCalendar/CVCalendar/pull/284) ([oscarmorrison](https://github.com/oscarmorrison))
- Style changes [\#263](https://github.com/CVCalendar/CVCalendar/pull/263) ([dbmrq](https://github.com/dbmrq))
- Cleared all warnings and merged CVCalendar and Demo directories [\#261](https://github.com/CVCalendar/CVCalendar/pull/261) ([dbmrq](https://github.com/dbmrq))
- update for swift2.2 [\#259](https://github.com/CVCalendar/CVCalendar/pull/259) ([sairamkotha](https://github.com/sairamkotha))
- Update CHANGELOG.md [\#246](https://github.com/CVCalendar/CVCalendar/pull/246) ([bre7](https://github.com/bre7))

## [1.2.9](https://github.com/CVCalendar/CVCalendar/tree/1.2.9) (2016-02-16)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.2.8...1.2.9)

**Implemented enhancements:**

- delegate method that returns date only once the animation has finished [\#125](https://github.com/CVCalendar/CVCalendar/issues/125)
- ReloadData\(\) is missing [\#47](https://github.com/CVCalendar/CVCalendar/issues/47)

**Closed issues:**

- add date on supplementaryView [\#228](https://github.com/CVCalendar/CVCalendar/issues/228)
- Is there a way to draw separator lines between the dates?  [\#226](https://github.com/CVCalendar/CVCalendar/issues/226)
- Ignore [\#220](https://github.com/CVCalendar/CVCalendar/issues/220)
- Project warning, unused capture dayview [\#218](https://github.com/CVCalendar/CVCalendar/issues/218)
- CVCalendarView is blank [\#216](https://github.com/CVCalendar/CVCalendar/issues/216)
- Changing default background colours for current day and selected day [\#211](https://github.com/CVCalendar/CVCalendar/issues/211)
- when we click the day it want to display on the addevent view controller. i am using cvcalendar. [\#207](https://github.com/CVCalendar/CVCalendar/issues/207)
- How to remove the lines of the calenderView i dont want to see the lines of each day [\#206](https://github.com/CVCalendar/CVCalendar/issues/206)
- Menuview graphical bug after commitMenuViewUpdate\(\) [\#205](https://github.com/CVCalendar/CVCalendar/issues/205)
- AppearanceDelegate [\#203](https://github.com/CVCalendar/CVCalendar/issues/203)
- MenuView and CalendarView Misaligned [\#195](https://github.com/CVCalendar/CVCalendar/issues/195)
- Throwing \*\*nill\*\* on dayview.day.year ! [\#187](https://github.com/CVCalendar/CVCalendar/issues/187)
- CVCalendar for Objective-C [\#183](https://github.com/CVCalendar/CVCalendar/issues/183)
- Getting Error When Declaring CalandarView [\#182](https://github.com/CVCalendar/CVCalendar/issues/182)
- How add dates to be marked on the Calendar? [\#179](https://github.com/CVCalendar/CVCalendar/issues/179)
- Pod version 1.2.7 is not updated [\#170](https://github.com/CVCalendar/CVCalendar/issues/170)
- Calendar reload [\#156](https://github.com/CVCalendar/CVCalendar/issues/156)

**Merged pull requests:**

- Fix codestyle [\#231](https://github.com/CVCalendar/CVCalendar/pull/231) ([danshevluk](https://github.com/danshevluk))
- Correct the spelling of CocoaPods in README [\#227](https://github.com/CVCalendar/CVCalendar/pull/227) ([ReadmeCritic](https://github.com/ReadmeCritic))
- Added weak references to delegates to prevent memory leakage. [\#219](https://github.com/CVCalendar/CVCalendar/pull/219) ([kadarandras](https://github.com/kadarandras))
- Carthage compatible project [\#214](https://github.com/CVCalendar/CVCalendar/pull/214) ([sprint84](https://github.com/sprint84))
- Adds a way to use a custom shape for single selection instead of the default circle [\#181](https://github.com/CVCalendar/CVCalendar/pull/181) ([ts-alexandros](https://github.com/ts-alexandros))

## [1.2.8](https://github.com/CVCalendar/CVCalendar/tree/1.2.8) (2015-12-11)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.2.7...1.2.8)

**Implemented enhancements:**

- Xode 6.3 beta using Swift v1.2 [\#42](https://github.com/CVCalendar/CVCalendar/issues/42)

**Closed issues:**

- Remove line between each week for month view? [\#184](https://github.com/CVCalendar/CVCalendar/issues/184)
- reload dots [\#177](https://github.com/CVCalendar/CVCalendar/issues/177)
- Reloading calendar? [\#175](https://github.com/CVCalendar/CVCalendar/issues/175)
- Initialize Selected Date [\#168](https://github.com/CVCalendar/CVCalendar/issues/168)
- Crashing in ios 8.2 [\#166](https://github.com/CVCalendar/CVCalendar/issues/166)
- Eliminate Circle and Dot markers [\#165](https://github.com/CVCalendar/CVCalendar/issues/165)
- Seems the Calendar isn't Working At All \(iOS 9.1.2\) [\#154](https://github.com/CVCalendar/CVCalendar/issues/154)
- Convert an NSDate, or string, or cvdate, to DayView? Possible? [\#152](https://github.com/CVCalendar/CVCalendar/issues/152)
- CVCalendarViewDelegate didSelectDayView\(animationDidFinish:\) does not exist [\#151](https://github.com/CVCalendar/CVCalendar/issues/151)
- some errors for latest version of swift [\#149](https://github.com/CVCalendar/CVCalendar/issues/149)
- When I set the calendar view height as percentage of the parent's view's height, it give me warnings [\#147](https://github.com/CVCalendar/CVCalendar/issues/147)
- Reload dot markers manually. [\#145](https://github.com/CVCalendar/CVCalendar/issues/145)
- Loading dates on calendar from remote JSON web service [\#143](https://github.com/CVCalendar/CVCalendar/issues/143)
- Can't get calendar to render properly [\#141](https://github.com/CVCalendar/CVCalendar/issues/141)
- system lang error [\#140](https://github.com/CVCalendar/CVCalendar/issues/140)
- Error on version 126 \(Swift 2.0\) [\#133](https://github.com/CVCalendar/CVCalendar/issues/133)
- converting CVDate to NSDate [\#130](https://github.com/CVCalendar/CVCalendar/issues/130)
- Marking dots [\#114](https://github.com/CVCalendar/CVCalendar/issues/114)
- Swift 2.0 support [\#113](https://github.com/CVCalendar/CVCalendar/issues/113)

**Merged pull requests:**

- Fix issue where new dot views have not been added properly on refresh… [\#180](https://github.com/CVCalendar/CVCalendar/pull/180) ([ts-alexandros](https://github.com/ts-alexandros))
- Ability for refresh and removal of dot views [\#160](https://github.com/CVCalendar/CVCalendar/pull/160) ([joelwass](https://github.com/joelwass))
- Added in method for demo to delete circle view and dot on dayView [\#155](https://github.com/CVCalendar/CVCalendar/pull/155) ([joelwass](https://github.com/joelwass))
- Add bool argument to didSelectDayView delegate method [\#137](https://github.com/CVCalendar/CVCalendar/pull/137) ([hffmnn](https://github.com/hffmnn))

## [1.2.7](https://github.com/CVCalendar/CVCalendar/tree/1.2.7) (2015-10-16)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.2.6...1.2.7)

**Closed issues:**

- Not working on Swift 2.0 [\#123](https://github.com/CVCalendar/CVCalendar/issues/123)

**Merged pull requests:**

- Show Months delegate methods [\#136](https://github.com/CVCalendar/CVCalendar/pull/136) ([nexon](https://github.com/nexon))
- Adds a delegate method to prevent scrolling to the previous/next view on selection [\#134](https://github.com/CVCalendar/CVCalendar/pull/134) ([Paulo-Branco](https://github.com/Paulo-Branco))

## [1.2.6](https://github.com/CVCalendar/CVCalendar/tree/1.2.6) (2015-10-13)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.2.5...1.2.6)

**Merged pull requests:**

- Dot marker size can be varied using delegate  [\#132](https://github.com/CVCalendar/CVCalendar/pull/132) ([sandeepmenon](https://github.com/sandeepmenon))
- Dot marker size can be varied using a delegate 'sizeOnDayView' -\> flo… [\#131](https://github.com/CVCalendar/CVCalendar/pull/131) ([sandeepmenon](https://github.com/sandeepmenon))
- Update Podspec for latest tag [\#124](https://github.com/CVCalendar/CVCalendar/pull/124) ([elsesiy](https://github.com/elsesiy))

## [1.2.5](https://github.com/CVCalendar/CVCalendar/tree/1.2.5) (2015-10-13)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.2.0...1.2.5)

**Closed issues:**

- How to get a event after scroll month or calendar reload? [\#118](https://github.com/CVCalendar/CVCalendar/issues/118)

**Merged pull requests:**

- Adds delegate methods to turn off the auto selection on month/week change. [\#129](https://github.com/CVCalendar/CVCalendar/pull/129) ([Paulo-Branco](https://github.com/Paulo-Branco))
- Added the ability to change the weekday symbol type for the CVCalendarMenu [\#127](https://github.com/CVCalendar/CVCalendar/pull/127) ([yavinfour](https://github.com/yavinfour))
- It was corrected so that a build might pass in Xcode7. [\#120](https://github.com/CVCalendar/CVCalendar/pull/120) ([karamage](https://github.com/karamage))

## [1.2.0](https://github.com/CVCalendar/CVCalendar/tree/1.2.0) (2015-09-14)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.1.4...1.2.0)

**Implemented enhancements:**

- Spelling error [\#43](https://github.com/CVCalendar/CVCalendar/issues/43)
- Adding more dots per day [\#27](https://github.com/CVCalendar/CVCalendar/issues/27)
- Animating between CVCalendarViewModes [\#17](https://github.com/CVCalendar/CVCalendar/issues/17)

**Fixed bugs:**

- Spelling error [\#43](https://github.com/CVCalendar/CVCalendar/issues/43)
- Animating between CVCalendarViewModes [\#17](https://github.com/CVCalendar/CVCalendar/issues/17)

**Merged pull requests:**

- Swift 2.0 changes [\#115](https://github.com/CVCalendar/CVCalendar/pull/115) ([elsesiy](https://github.com/elsesiy))

## [1.1.4](https://github.com/CVCalendar/CVCalendar/tree/1.1.4) (2015-08-28)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.1.3...1.1.4)

**Closed issues:**

- Compile Errors [\#106](https://github.com/CVCalendar/CVCalendar/issues/106)

## [1.1.3](https://github.com/CVCalendar/CVCalendar/tree/1.1.3) (2015-08-28)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.1.2...1.1.3)

**Closed issues:**

- \[1.1.0\] CocoaPods integration  [\#111](https://github.com/CVCalendar/CVCalendar/issues/111)

## [1.1.2](https://github.com/CVCalendar/CVCalendar/tree/1.1.2) (2015-08-28)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.1.1...1.1.2)

**Closed issues:**

- Selecting DayView Programatically [\#99](https://github.com/CVCalendar/CVCalendar/issues/99)
- Core Code for Calendar is under Demo in Develop Branch [\#74](https://github.com/CVCalendar/CVCalendar/issues/74)

## [1.1.1](https://github.com/CVCalendar/CVCalendar/tree/1.1.1) (2015-06-30)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.1.0...1.1.1)

**Implemented enhancements:**

- Calendar Graphing [\#61](https://github.com/CVCalendar/CVCalendar/issues/61)
- Selected date gone after swiping two months forwards  and back. [\#37](https://github.com/CVCalendar/CVCalendar/issues/37)
- Init CVCalendar with a specific day in current month [\#30](https://github.com/CVCalendar/CVCalendar/issues/30)

**Fixed bugs:**

- Latest version not working without autolayout? [\#72](https://github.com/CVCalendar/CVCalendar/issues/72)
- Navigating between months quickly causes program to crash [\#57](https://github.com/CVCalendar/CVCalendar/issues/57)
- Current calendar date does not update when date changes.  [\#51](https://github.com/CVCalendar/CVCalendar/issues/51)
- Current day highlighted text overlay bug.  [\#48](https://github.com/CVCalendar/CVCalendar/issues/48)
- CVCalendarView doesn't load on when Simulated Metric == iPhone 4-inch [\#46](https://github.com/CVCalendar/CVCalendar/issues/46)
- Cannot get date on didSelectDayView [\#41](https://github.com/CVCalendar/CVCalendar/issues/41)
- Appearance Doesn't update for the next and previous months [\#34](https://github.com/CVCalendar/CVCalendar/issues/34)
- Labels for all the dates repeatedly getting darker with each frame update on viewDidAppear on projects with uitabbarcontrollers [\#31](https://github.com/CVCalendar/CVCalendar/issues/31)
- Returning to CVCalendar with a selected date renders day label incorrectly [\#22](https://github.com/CVCalendar/CVCalendar/issues/22)
- Calling didSelectDayView immediately on load [\#18](https://github.com/CVCalendar/CVCalendar/issues/18)

**Closed issues:**

- Clicking on a date outside of the current month [\#88](https://github.com/CVCalendar/CVCalendar/issues/88)
- Demo not working [\#85](https://github.com/CVCalendar/CVCalendar/issues/85)
- Make calendar resize without using a height constraint [\#76](https://github.com/CVCalendar/CVCalendar/issues/76)
- How do I pre-select a date in the calendar? [\#73](https://github.com/CVCalendar/CVCalendar/issues/73)
- Not displaying all dates for month [\#65](https://github.com/CVCalendar/CVCalendar/issues/65)
- Changing Month Label [\#60](https://github.com/CVCalendar/CVCalendar/issues/60)
- Dotmarker pops on top of day when switching to another month when the standard selected day has a dot programmed on it [\#59](https://github.com/CVCalendar/CVCalendar/issues/59)
- nil data for calendarDayViews once the month is scrolled past the buffer. [\#58](https://github.com/CVCalendar/CVCalendar/issues/58)
- Ability to jump to any month [\#56](https://github.com/CVCalendar/CVCalendar/issues/56)
- Must call a designated initializer of the superclass 'UIViewController' [\#53](https://github.com/CVCalendar/CVCalendar/issues/53)
- Initializer does not override a designated initializer from its superclass [\#52](https://github.com/CVCalendar/CVCalendar/issues/52)
- Scrolling into the past [\#39](https://github.com/CVCalendar/CVCalendar/issues/39)
- Can not view MonthView mode [\#38](https://github.com/CVCalendar/CVCalendar/issues/38)
- i want to add some event for dates ?  [\#26](https://github.com/CVCalendar/CVCalendar/issues/26)

**Merged pull requests:**

- \[1.1.0\] Release – Beta [\#90](https://github.com/CVCalendar/CVCalendar/pull/90) ([mozharovsky](https://github.com/mozharovsky))
- Add delegates for MenuView capitalization, color, and font [\#86](https://github.com/CVCalendar/CVCalendar/pull/86) ([jkeen](https://github.com/jkeen))
- Made it so users can add multiple dots per day and created optional delegate preliminaryView [\#84](https://github.com/CVCalendar/CVCalendar/pull/84) ([thomasbaldwin](https://github.com/thomasbaldwin))
- Add automatically generated change log file [\#83](https://github.com/CVCalendar/CVCalendar/pull/83) ([skywinder](https://github.com/skywinder))
- Added Sup delegate methods [\#64](https://github.com/CVCalendar/CVCalendar/pull/64) ([Trifusion](https://github.com/Trifusion))
- Fixed spelling error [\#44](https://github.com/CVCalendar/CVCalendar/pull/44) ([mengelhart](https://github.com/mengelhart))

## [1.1.0](https://github.com/CVCalendar/CVCalendar/tree/1.1.0) (2015-04-15)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.0.8...1.1.0)

**Implemented enhancements:**

- Showing 1 week [\#13](https://github.com/CVCalendar/CVCalendar/issues/13)

**Fixed bugs:**

- Calendar not working properly [\#45](https://github.com/CVCalendar/CVCalendar/issues/45)

**Closed issues:**

- iOS 8.3  [\#40](https://github.com/CVCalendar/CVCalendar/issues/40)
- CocoaPods integration [\#25](https://github.com/CVCalendar/CVCalendar/issues/25)
- CalendarMode [\#24](https://github.com/CVCalendar/CVCalendar/issues/24)
- Month update, event dot update [\#14](https://github.com/CVCalendar/CVCalendar/issues/14)

## [1.0.8](https://github.com/CVCalendar/CVCalendar/tree/1.0.8) (2015-01-29)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.0.6...1.0.8)

**Fixed bugs:**

- Can't run on iPhone 4 \(7.1.2\)  [\#7](https://github.com/CVCalendar/CVCalendar/issues/7)

**Closed issues:**

- Change selected date when toggleMonthViewWithDate is called [\#11](https://github.com/CVCalendar/CVCalendar/issues/11)
- Day animations stopped working [\#10](https://github.com/CVCalendar/CVCalendar/issues/10)

**Merged pull requests:**

- Single Week View Mode [\#16](https://github.com/CVCalendar/CVCalendar/pull/16) ([mozharovsky](https://github.com/mozharovsky))
- Update CVCalendarViewAppearance.swift [\#15](https://github.com/CVCalendar/CVCalendar/pull/15) ([marcpages](https://github.com/marcpages))

## [1.0.6](https://github.com/CVCalendar/CVCalendar/tree/1.0.6) (2015-01-18)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.0.5...1.0.6)

## [1.0.5](https://github.com/CVCalendar/CVCalendar/tree/1.0.5) (2015-01-17)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.0.2...1.0.5)

**Fixed bugs:**

- Demo - showing days our toggle not working [\#9](https://github.com/CVCalendar/CVCalendar/issues/9)

**Merged pull requests:**

- Changing starter weekday [\#8](https://github.com/CVCalendar/CVCalendar/pull/8) ([mozharovsky](https://github.com/mozharovsky))

## [1.0.2](https://github.com/CVCalendar/CVCalendar/tree/1.0.2) (2015-01-05)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.0.1...1.0.2)

## [1.0.1](https://github.com/CVCalendar/CVCalendar/tree/1.0.1) (2015-01-03)
[Full Changelog](https://github.com/CVCalendar/CVCalendar/compare/1.0.0...1.0.1)

## [1.0.0](https://github.com/CVCalendar/CVCalendar/tree/1.0.0) (2015-01-03)
**Implemented enhancements:**

- Month View Toggling [\#5](https://github.com/CVCalendar/CVCalendar/issues/5)
- Month loading [\#2](https://github.com/CVCalendar/CVCalendar/issues/2)
- Selection animation [\#1](https://github.com/CVCalendar/CVCalendar/issues/1)

**Fixed bugs:**

- Month View segue [\#4](https://github.com/CVCalendar/CVCalendar/issues/4)
- Segue on selecting days out [\#3](https://github.com/CVCalendar/CVCalendar/issues/3)