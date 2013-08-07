# Piecemaker2.app

__requires Mac OS 10.8 (64-bit)__

## Installation and Usage

Download [piecemaker2.dmg](https://github.com/motionbank/piecemaker2-app/raw/master/piecemaker2.dmg) and mount the .dmp file by clicking on it.

Drag and drop the Piecemaker2.app to your Mac (i.e. Desktop or Applications directory).

Unmount the .dmg file in Finder and start the Piecemaker2.app, which you just drag & dropped to your Mac.

Select the location for your data directory. You may want to create a new directory for this, i.e. on your Desktop.

Click Start and wait some seconds. The API will now load. This may take a while, if this is a fresh data directory.


## Troubleshooting

 * __How-to re-create databases?__  
   Quit the app, if running. Delete ```local/var/pgsql/data``` in the .app package resources. Restart app.

 * __The app crashed. It seems as if i can't connect to the DB anymore?!__  
   Make sure there is no orphaned postgresql server process.  
   ```
   $ ps aux | grep postgres
   $ kill %ID%
   ```

 * __Ruby process__  
   ```
   $ ps aux | grep ruby
   $ kill %ID%
   ```

 * __Finding logs in ...__  
   ```
   piecemaker2.app/Contents/Resources/app/api/logs
   piecemaker2.app/Contents/Resources/local/var/pgsql/
   ```

 * __DMG file issues__  
   ! The .app won't run, when started within the original .dmg file.


-----------------

## Development

__FYI__ Find the actual .app file in ```piecemaker2/DerivedData/piecemaker2/Build/Products/Debug/piecemaker2.app```.

### Building piecemaker2.app

Ruby is compiled with the help of [ruby-build](https://github.com/sstephenson/ruby-build). Install with ```brew install ruby-build```.

  1) ```rake compile:all``` (or see ```rake``` for sub tasks)  
  2) Build piecemaker2.app with XCode  
  3) ```rake dmg```   



-----------------

```
# set prefix variable
cd piecemaker2-app/piecemaker2
prefix=$(pwd)/local


# compile ruby
CONFIGURE_OPTS="--disable-install-doc"
ruby-build 2.0.0-p247 $prefix


# compile PostgreSQL
# http://www.postgresql.org/ftp/source/
cd postgresql-9.2.4
./configure --prefix=$prefix
make
make install


# install bundler
./local/bin/gem install bundler

../../local/bin/bundle install --disable-shared-gems

````



## Setup during installation

````
# setup PostgreSQL
# no other PostgreSQL instance should be running
# if you get an error like 'FATAL:  could not create shared memory segment: Cannot allocate memory', make sure to quit all other running PostgreSQL processes

mkdir -p local/var/pgsql/data
./local/bin/initdb -D local/var/pgsql/data 

# update postgresql.conf
sed -i '' -e 's/#port = 5432/port = 50725/' local/var/pgsql/data/postgresql.conf
sed -i '' -e "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" local/var/pgsql/data/postgresql.conf

# start postgresql server with data dir
./local/bin/postgres -D local/var/pgsql/data

# create databases in another proceess while server is running
./local/bin/createdb --host=localhost --port=50725 piecemaker2_test | ..prod,dev

# optional: connect with psql client
./local/bin/psql --host=localhost --port=50725 piecemaker2_dev

````



