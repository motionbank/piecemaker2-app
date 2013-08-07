# Piecemaker2.app

__requires Mac OS 10.8 (64-bit)__

## Installation and Usage

Download [piecemaker2.dmg](https://github.com/motionbank/piecemaker2-app/raw/master/piecemaker2.dmg) and mount the .dmp file by clicking on it.

Drag and drop the Piecemaker2.app to your Mac (i.e. Desktop or Applications directory).

Unmount the .dmg file in Finder and start the Piecemaker2.app, which you just drag & dropped to your Mac.

Select the location for your data directory. You may want to create a new directory for this, i.e. on your Desktop.

Click Start and wait some seconds. The API will now load. This may take a while, if this is a fresh data directory.


## Troubleshooting

 * __I got an error and the App quits!__  
   This is alpha software. Submit an issue [here](https://github.com/motionbank/piecemaker2-app/issues).

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



-----------------

## Development

__FYI__ Find the actual .app file in ```piecemaker2/DerivedData/piecemaker2/Build/Products/Debug/piecemaker2.app```.

### Building piecemaker2.app

Ruby is compiled with the help of [ruby-build](https://github.com/sstephenson/ruby-build). Install with ```brew install ruby-build```.

  1) ```rake compile:all``` (or see ```rake``` for sub tasks)  
  2) Build piecemaker2.app with XCode  
  3) ```rake dmg```   







-----------------

[Some old readme stuff](https://github.com/motionbank/piecemaker2-app/tree/9844e2f8dba950c83f65eac1e01593ae97d7b0cc)



