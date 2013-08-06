# Piecemaker2.app

__requires Mac OS 10.8 (64-bit)__

Download [piecemaker2.dmg](https://github.com/motionbank/piecemaker2-app/raw/master/piecemaker2.dmg), 
open the app, click the "Test" button. It should print something like this:

```
workingDir:
/Users/mattes/Developer/piecemaker2-app/piecemaker2.app

which ruby:
/Users/mattes/Developer/piecemaker2-app/piecemaker2.app/Contents/Resources/local/bin/ruby

stdout:
Hello, Ruby!
```


## Compiling for .app

We are going to compile ruby with [ruby-build](https://github.com/sstephenson/ruby-build). Install with ```brew install ruby-build```.


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

# initial api config and gem installation
cd app/api/
cp config/config.sample.yml config/config.yml
../../local/bin/bundle install

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



