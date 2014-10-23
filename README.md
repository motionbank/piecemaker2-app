# Piecemaker2.app

__requires Mac OS 10.8 (64-bit)__

## Installation and Usage

Download [piecemaker2.dmg](http://pm2.motionbank.org/piecemaker2.dmg) and mount the .dmg file by clicking on it.

__IMPORTANT: Drag and drop the Piecemaker2.app into the /Applications directory__. 
Be careful, that you really use ```/Applications``` and not ```/Users/xyz/Applications```. The latter won't work.

Unmount the .dmg file in Finder and start the Piecemaker2.app, which you just drag & dropped to /Applications.

Select the location for your data directory. You may want to create a new directory for this, i.e. on your Desktop. The location of the data directory
doesn't matter.

Click Start and wait some seconds. The API will now load. This may take a while, if this is a fresh data directory.


## Troubleshooting

 * __I got an error and the App quits!__  
   This is alpha software. Submit an issue [here](https://github.com/motionbank/piecemaker2-app/issues). Please include your logfiles (see below) and the 
   content from Window > Developer > 'Get Env Info' and 'Run Specs' (see in app).

   Sometimes it helps to kill all ```ruby``` and ```postgres``` processes:

   ```
   $ ps aux | grep postgres
   $ ps aux | grep ruby
   $ kill %PID%
   ```

 * __Where are log files?__  
   ```
   piecemaker2.app/Contents/Resources/app/api/log/daemon_production.log
   piecemaker2.app/Contents/Resources/app/frontend/rack_http_server.log
   [your data dir]/pqsqllog.log
   ```

   Please consider to open ```/Applications/Utilities/Console.app``` before
   starting the actual Piecemaker2.app. Search for ```piecemaker2``` to get
   realtime in-app logs.

 * __Missing write permissions?!__  
   Please don't run Piecemaker2.app from within the .dmg file.
   Copy Piecemaker2.app into the /Applications directory.

 * __Window > Developer > Get Env__  
   The output should look like this:

   ```
   $ pwd
   /Applications/Piecemaker2.app/Contents/Resources

   $ which ruby
   /Applications/Piecemaker2.app/Contents/Resources/local/bin/ruby

   $ ruby -v
   ruby 2.0.0p247 (2013-06-27 revision 41674) [x86_64-darwin12.4.0]

   $ which rake
   /Applications/Piecemaker2.app/Contents/Resources/local/bin/rake

   $ which bundle
   /Applications/Piecemaker2.app/Contents/Resources/local/bin/bundle

   $ cd app/api && bundle show pg
   /Applications/Piecemaker2.app/Contents/Resources/local/lib/ruby/gems/2.0.0/gems/pg-0.15.1

   $ gem env
   RubyGems Environment:
     - RUBYGEMS VERSION: 2.0.3
     - RUBY VERSION: 2.0.0 (2013-06-27 patchlevel 247) [x86_64-darwin12.4.0]
     - INSTALLATION DIRECTORY: /Applications/Piecemaker2.app/Contents/Resources/local/lib/ruby/gems/2.0.0
     - RUBY EXECUTABLE: /Applications/Piecemaker2.app/Contents/Resources/local/bin/ruby
     - EXECUTABLE DIRECTORY: /Applications/Piecemaker2.app/Contents/Resources/local/bin
     - RUBYGEMS PLATFORMS:
       - ruby
       - x86_64-darwin-12
     - GEM PATHS:
        - /Applications/Piecemaker2.app/Contents/Resources/local/lib/ruby/gems/2.0.0
        - /Applications/Piecemaker2.app/Contents/Resources/.gem/ruby/2.0.0
     - GEM CONFIGURATION:
        - :update_sources => true
        - :verbose => true
        - :backtrace => false
        - :bulk_threshold => 1000
     - REMOTE SOURCES:
        - https://rubygems.org/
   ```



-----------------

## Development

__FYI__ Find the actual .app file in ```piecemaker2/DerivedData/piecemaker2/Build/Products/Debug/piecemaker2.app```.

### Building piecemaker2.app

Ruby is compiled with the help of [ruby-build](https://github.com/sstephenson/ruby-build). Install with ```brew install ruby-build```.

  0) ```git submodule update --init --recursive``` to load the [api](https://github.com/motionbank/piecemaker2-api) and [frontend](https://github.com/motionbank/piecemaker2-frontend)

  1) ```rake compile:all``` (or see ```rake``` for compile sub tasks)  

  2) Build clean piecemaker2.app with XCode 

  3) You can test the locally created Piecemaker2.app or 
     if you want to test the global Piecemaker2.app in
     in /Applications, run 'rake compile:merge_app'.

  4) ```rake dmg``` to distribute the final .app in a .dmg file.  

## For Frontend-Developers

Do not work inside the app/frontend directory as it is not automatically included upon build.

Either work inside Piecemaker2.app/..../app/frontend or in a separate checkout and pull changes to refresh.

[FRONTEND-dev](FRONTEND-DEV.md)





-----------------

[Some old readme stuff](https://github.com/motionbank/piecemaker2-app/tree/9844e2f8dba950c83f65eac1e01593ae97d7b0cc)


http://www.evermeet.cx/ffmpeg/
http://wiki.webmproject.org/ffmpeg
