require "pathname"
require 'tmpdir'

task :default do
  exec("rake -T")
end  

namespace :compile do

  desc "compile ruby"
  task :ruby do
    system "cd piecemaker2;" +
           "prefix=$(pwd)/local;" +
           'CONFIGURE_OPTS="--disable-install-doc";' + 
           "ruby-build 2.0.0-p247 $prefix;"
  end

  desc "compile postgresql"
  task :postgres do
    # http://www.postgresql.org/ftp/source/
    system "cd piecemaker2;" +
           "prefix=$(pwd)/local;" +
           "cd ../postgresql-9.2.4;" + 
           "./configure --prefix=$prefix" +
           "make && make install"
  end

  desc "install bundler"
  task :gems do
    system "cd piecemaker2;" + 
           "./local/bin/gem install bundler;" +
           "cd app/api;" + 
           "../../local/bin/bundle install --disable-shared-gems"
  end

  desc "compile all"
  task :all do
    Rake::Task['compile:ruby'].execute
    Rake::Task['compile:postgres'].execute
    Rake::Task['compile:gems'].execute
  end

end


desc "create .dmg file from piecemaker.app"
task :dmg do

  # create tmp dir
  TMP_DIR = Pathname.new(Dir.mktmpdir)
  WORKING_DIR = Pathname.new(Dir.pwd)

  # copy piecemaker app to tmp dir
  system("cp -r #{WORKING_DIR + 'piecemaker2.app'} #{TMP_DIR}")

  # remove existing piecemaker2.dmg
  system("rm -rf '#{WORKING_DIR + 'piecemaker2.dmg'}'")

  # remove postgres data dir
  system("rm -rf #{TMP_DIR + 'piecemaker2.app/Contents/Resources/local/var/pqsql'}")

  # build dmg
  system("hdiutil create -fs HFS+ -volname 'Piecemaker2' \
    -srcfolder '#{TMP_DIR}' '#{WORKING_DIR + 'piecemaker2.dmg'}'")

  # remove tmp dir
  system("rm -rf #{TMP_DIR}")
end