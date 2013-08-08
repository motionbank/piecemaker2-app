require "pathname"
require 'tmpdir'

task :default do
  exec("rake -T")
end  

namespace :compile do

  desc "create /Applications/Piecemaker2.app folders"
  task :create_app_folder do
    path = "/Applications/Piecemaker2.app/Contents/Resources/local"
    system("mkdir -p #{path}") unless Dir.exist?(path)
  end

  desc "compile ruby"
  task :ruby do
    # compiling portable ruby
    # https://github.com/sstephenson/ruby-build/issues/42
    # http://yehudakatz.com/2012/06/
    
    # system "cd piecemaker2;" +
    #        "prefix=$(pwd)/local;" +
    #        'CONFIGURE_OPTS="--enable-load-relative --disable-install-doc";' + 
    #        "ruby-build 2.0.0-p247 $prefix;"

    Rake::Task['compile:create_app_folder'].execute

    system "cd /Applications/Piecemaker2.app/Contents/Resources;" +
           "prefix=$(pwd)/local;" +
           'CONFIGURE_OPTS="--enable-load-relative --disable-shared --disable-install-doc";' + 
           "ruby-build 2.0.0-p247 $prefix;"

  end

  desc "compile postgresql"
  task :postgres do
    # http://www.postgresql.org/ftp/source/
    # system "cd piecemaker2;" +
    #        "prefix=$(pwd)/local;" +
    #        "cd ../postgresql-9.2.4;" + 
    #        "./configure --prefix=$prefix;" +
    #        "make && make install"

    Rake::Task['compile:create_app_folder'].execute

    postgres_source_path = Dir.pwd + "/piecemaker2/postgresql-9.2.4"
    system "cd /Applications/Piecemaker2.app/Contents/Resources;" +
           "prefix=$(pwd)/local;" +
           "cd #{postgres_source_path};" + 
           "./configure --prefix=$prefix;" +
           "make && make install"
  end

  desc "copy piecemaker2/app to /Applications/Piecemaker2.app"
  task :copy_api_and_frontend do
    Rake::Task['compile:create_app_folder'].execute

    system("cp -R piecemaker2/app " +
           "/Applications/Piecemaker2.app/Contents/Resources")
  end

  desc "merge freshly build Piecemaker2.app with /Applications/Piecemaker2.app"
  task :merge_app do
    Rake::Task['compile:create_app_folder'].execute    

    fresh_app = Dir.pwd + "/piecemaker2/DerivedData/piecemaker2/Build/Products/Debug/piecemaker2.app"

    global_app = "/Applications/Piecemaker2.app"

    system("cp #{fresh_app}/Contents/Info.plist " + 
           "#{global_app}/Contents")

    system("cp -R #{fresh_app}/Contents/MacOS " + 
           "#{global_app}/Contents")

    system("cp #{fresh_app}/Contents/PkgInfo " + 
           "#{global_app}/Contents")

    system("cp #{fresh_app}/Contents/Resources/ApiController.nib " + 
           "#{global_app}/Contents/Resources")

    system("cp #{fresh_app}/Contents/Resources/DeveloperController.nib " + 
           "#{global_app}/Contents/Resources")

    system("cp #{fresh_app}/Contents/Resources/RecorderController.nib " + 
           "#{global_app}/Contents/Resources")

    system("cp -R #{fresh_app}/Contents/Resources/en.lproj " + 
           "#{global_app}/Contents/Resources")

  end

  desc "install bundler and gems"
  task :gems do
    # # delete Gemfile.lock in app/api if exists
    # if File.exist?("piecemaker2/app/api/Gemfile.lock")
    #   File.delete("piecemaker2/app/api/Gemfile.lock") 
    # end

    # system "cd piecemaker2/app/api;" + 
    #   "../../local/bin/gem install bundler;" +
    #   "../../local/bin/bundle install --no-deployment --shebang ../../local/bin/ruby && " +
    #   "../../local/bin/bundle install --deployment --shebang ../../local/bin/ruby;"

    Rake::Task['compile:create_app_folder'].execute    

    gemlock_file = "/Applications/Piecemaker2.app/Contents/Resources/app/api/Gemfile.lock"
    File.delete(gemlock_file) if File.exist?(gemlock_file)

    system "cd /Applications/Piecemaker2.app/Contents/Resources/app/api; " +
    "PATH=/Applications/Piecemaker2.app/Contents/Resources/local/bin:$PATH; " +
    "gem install bundler; " + # VERY IMPORTANT!!
    "bundle install --clean"
    # "bundle install --no-deployment --clean; " +
    # "bundle install --deployment; "

  end

  namespace :all do

    desc "compile before xcode"
    task :before_xcode do
      Rake::Task['compile:create_app_folder'].execute
      Rake::Task['compile:ruby'].execute
      Rake::Task['compile:postgres'].execute
      Rake::Task['compile:copy_api_and_frontend'].execute
      Rake::Task['compile:gems'].execute

      puts "---------------------"
      puts "---------------------"
      puts "Now compile Piecemaker2.app with XCode!"
    end

    desc "compile after xcode"
    task :after_xcode do
      Rake::Task['compile:merge_app'].execute
    end

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

  # remove existing config.yml
  system("rm  #{TMP_DIR + 'piecemaker2.app/Contents/Resources/app/api/config/config.yml'}")

  # remove "global gems" since we are using gems in vendor directory
  # save about 50MB!
  system("rm -rf #{TMP_DIR + 'piecemaker2.app/Contents/Resources/local/lib/ruby/gems'}")


  # build dmg
  system("hdiutil create -fs HFS+ -volname 'Piecemaker2' \
    -srcfolder '#{TMP_DIR}' '#{WORKING_DIR + 'piecemaker2.dmg'}'")

  # remove tmp dir
  system("rm -rf #{TMP_DIR}")
end