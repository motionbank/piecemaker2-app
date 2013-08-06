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
```
prefix=$(pwd)/local
cd postgresql-9.2.4
./configure --prefix=$prefix && make && make install
```