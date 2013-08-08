require "pathname"
require 'tmpdir'

task :default do
  exec("rake -T")
end  

namespace :compile do

  desc "compile ruby"
  task :ruby do
    # http://yehudakatz.com/2012/06/
    system "cd piecemaker2;" +
           "prefix=$(pwd)/local;" +
           'CONFIGURE_OPTS="--enable-load-relative --disable-install-doc";' + 
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

  desc "install bundler and gems"
  task :gems do
    # delete Gemfile.lock in app/api if exists
    if File.exist?("piecemaker2/app/api/Gemfile.lock")
      File.delete("piecemaker2/app/api/Gemfile.lock") 
    end

    system "cd piecemaker2/app/api;" + 
      "../../local/bin/gem install bundler;" +
      "../../local/bin/bundle install --no-deployment --shebang ../../local/bin/ruby && " +
      "../../local/bin/bundle install --deployment --shebang ../../local/bin/ruby;"
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

  puts "Creating .dmg file. This will take while..."

  # create tmp dir
  TMP_DIR = Pathname.new(Dir.mktmpdir)
  WORKING_DIR = Pathname.new(Dir.pwd)

  # copy piecemaker app to tmp dir
  system("cp -r #{WORKING_DIR + 'piecemaker2/DerivedData/piecemaker2/Build/Products/Debug/piecemaker2.app'} #{TMP_DIR}")

  # remove existing piecemaker2.dmg
  system("rm -rf '#{WORKING_DIR + 'piecemaker2.dmg'}'")

  # remove anything in local/var
  system("rm -rf #{TMP_DIR + 'piecemaker2.app/Contents/Resources/local/var/'}")

  # remove "global gems" since we are using gems in vendor directory
  # save about 50MB!
  system("rm -rf #{TMP_DIR + 'piecemaker2.app/Contents/Resources/local/lib/ruby/gems'}")


  # build dmg
  system("hdiutil create -fs HFS+ -volname 'Piecemaker2' \
    -srcfolder '#{TMP_DIR}' '#{WORKING_DIR + 'piecemaker2.dmg'}'")

  # remove tmp dir
  system("rm -rf #{TMP_DIR}")
end