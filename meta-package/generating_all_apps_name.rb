require 'open-uri'

BASE_URL='https://raw.githubusercontent.com/balaswecha/deb-packaging/master/phetsims/';

def download_app(classification_of_deb_packages)
  all_apps_names = open("#{BASE_URL}#{classification_of_deb_packages}/apps.rb") {|f| f.read };
  File.write("./all_apps/#{classification_of_deb_packages}_apps.rb",all_apps_names);
end

download_app('java');
download_app('html');
download_app('flash');



