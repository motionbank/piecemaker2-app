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

## Compiling

### Ruby

```
prefix=$(pwd)/local
cd ruby-2_0_0_247
autoconf
./configure --prefix=$prefix && make && make install
```

### PostgreSQL
https://github.com/mxcl/homebrew/blob/master/Library/Formula/postgresql.rb
```
prefix=$(pwd)/local
cd postgresql-9.2.4
./configure --prefix=$prefix && make && make install
cd ..

---
# no other postgres instance may be running
mkdir -p local/var/pgsql/data
./local/bin/initdb -D local/var/pgsql/data 

sed -i '' -e 's/#port = 5432/port = 50725/' local/var/pgsql/data/postgresql.conf
sed -i '' -e "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" local/var/pgsql/data/postgresql.conf

./local/bin/postgres -D local/var/pgsql/data
./local/bin/createdb --host=localhost --port=50725 piecemaker2_test | ..prod,dev


./local/bin/psql --host=localhost --port=50725 piecemaker2_dev




```







````
$ ./local/bin/initdb -D local/var/pgsql/data
The files belonging to this database system will be owned by user "mattes".
This user must also own the server process.

The database cluster will be initialized with locale "de_DE.UTF-8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "german".

fixing permissions on existing directory local/var/pgsql/data ... ok
creating subdirectories ... ok
selecting default max_connections ... 10
selecting default shared_buffers ... 400kB
creating configuration files ... ok
creating template1 database in local/var/pgsql/data/base/1 ... FATAL:  could not create shared memory segment: Cannot allocate memory
DETAIL:  Failed system call was shmget(key=1, size=2072576, 03600).
HINT:  This error usually means that PostgreSQL's request for a shared memory segment exceeded available memory or swap space, or exceeded your kernel's SHMALL parameter.  You can either reduce the request size or reconfigure the kernel with larger SHMALL.  To reduce the request size (currently 2072576 bytes), reduce PostgreSQL's shared memory usage, perhaps by reducing shared_buffers or max_connections.
  The PostgreSQL documentation contains more information about shared memory configuration.
child process exited with exit code 1
initdb: removing contents of data directory "local/var/pgsql/data"
````