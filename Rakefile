require "pathname"
require 'tmpdir'

task :default do
  exec("rake -T")
end  

namespace :dev do
  desc "replace global app/api with git repo"
  task :api_to_git do

    puts "Please specify API Git URL:"
    puts "[https://github.com/motionbank/piecemaker2-api.git]"

    url = STDIN.gets.to_s.chomp
    if url == "" 
      puts "empty url... quitting"
      exit 1
    end

    system "" +
      "rm -rf /Applications/Piecemaker2.app/Contents/Resources/app/api && " +
      "git clone #{url} " +
        "/Applications/Piecemaker2.app/Contents/Resources/app/api;"
  end


  desc "replace global app/frontend with git repo"
  task :frontend_to_git do

    puts "Please specify Frontend Git URL:"
    puts "[https://github.com/motionbank/piecemaker2-frontend.git]"

    url = STDIN.gets.to_s.chomp
    if url == "" 
      puts "empty url... quitting"
      exit 1
    end

    system "" +
      "rm -rf /Applications/Piecemaker2.app/Contents/Resources/app/frontend && " +
      "git clone #{url} " +
        "/Applications/Piecemaker2.app/Contents/Resources/app/frontend"
  end
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

  end

  desc "compile all"
  task :all do
      Rake::Task['compile:create_app_folder'].execute
      Rake::Task['compile:ruby'].execute
      Rake::Task['compile:postgres'].execute
      Rake::Task['compile:copy_api_and_frontend'].execute
      Rake::Task['compile:gems'].execute

      puts ""
      puts ""
      puts "-----------------------------------------------------"
      puts "-----------------------------------------------------"
      puts "Now compile Piecemaker2.app with XCode and test it."
      puts ""
      puts "You can test the locally created Piecemaker2.app or"
      puts "if you want to test the global Piecemaker2.app in"
      puts "in /Applications, run 'rake compile:merge_app'."
      puts ""
      puts "Once you are ready to create the final Piecemaker2.app"
      puts "package, run 'rake dmg'."
      puts ""
      puts "-----------------------------------------------------"
      puts "-----------------------------------------------------"
      puts ""
  end

end

desc "upload .dmg file to server"
task :upload_dmg do
  puts "FTP-Host: "
  host = STDIN.gets.strip

  puts "Username: "
  username = STDIN.gets.strip

  puts "Password: "
  password = STDIN.gets.strip

  system("lftp -e 'set ssl:verify-certificate no; put piecemaker2.dmg; bye' -u #{username},#{password} #{host}")
end

desc "create .dmg file from piecemaker.app in /Applications directory"
task :dmg do

  puts "Creating .dmg file. This will take while..."

  Rake::Task['compile:merge_app'].execute

  # create tmp dir
  TMP_DIR = Pathname.new(Dir.mktmpdir)
  WORKING_DIR = Pathname.new(Dir.pwd)

  # copy piecemaker app to tmp dir
  system("cp -r /Applications/Piecemaker2.app #{TMP_DIR}")

  # remove existing piecemaker2.dmg
  system("rm -rf '#{WORKING_DIR + 'piecemaker2.dmg'}'")

  # remove anything in local/var
  system("rm -rf #{TMP_DIR + 'piecemaker2.app/Contents/Resources/local/var/'}")

  # remove existing config.yml
  system("rm  #{TMP_DIR + 'piecemaker2.app/Contents/Resources/app/api/config/config.yml'}")

  # remove .git dirs
  system("rm -rf #{TMP_DIR + 'piecemaker2.app/Contents/Resources/app/api/.git'}")
  system("rm -rf #{TMP_DIR + 'piecemaker2.app/Contents/Resources/app/frontend/.git'}")

  # remove openssl man pages
  system("rm -rf #{TMP_DIR + 'piecemaker2.app/Contents/Resources/local/openssl/ssl/man'}")

  # include some symlinks
  system("ln -s /Applications #{TMP_DIR}/Applications")

  # build dmg
  system("hdiutil create -fs HFS+ -volname 'Piecemaker2' \
    -srcfolder '#{TMP_DIR}' '#{WORKING_DIR + 'piecemaker2.dmg'}'")

  # remove tmp dir
  system("rm -rf #{TMP_DIR}")
end