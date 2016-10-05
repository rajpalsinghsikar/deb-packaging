#!/usr/bin/env ruby

videos_meta_file = './videos.rb'
require videos_meta_file
key_file = '../key.rb'
require key_file

$current_date = `date -I`
$current_date = $current_date.chomp

def create_package(pkg_name)

   `curl -v -u#{$key} -H "Content-Type: application/json" -X POST https://api.bintray.com/packages/balaswecha/balaswecha-dev --data '{ \"name\": \"#{pkg_name}\", \"licenses\": [ \"GPL-3.0\" ], \"website_url\":\"https://balaswecha.in", \"vcs_url\":\"https://github.com/balaswecha/deb-packaging\" }'` 

end

def create_version(pkg_name)

   `curl -v -u#{$key} -H "Content-Type: application/json" -X POST https://api.bintray.com/packages/balaswecha/balaswecha-dev/#{pkg_name}/versions --data '{ \"name\": \"1.0-1\", \"release_notes\": \"auto\",\"released\": \"#{$current_date}\" }'`

end

def upload_package(pkg_name)

`curl -v -u#{$key} -H "X-Bintray-Debian-Distribution: trusty,xenial,jessie,stretch" -H "X-Bintray-Debian-Component: main" -H "X-Bintray-Debian-Architecture: all" -H "publish:1" -X PUT -T #{pkg_name}_1.0-1_all.deb https://api.bintray.com/content/balaswecha/balaswecha-dev/#{pkg_name}/1.0-1/pool/main/#{pkg_name}/#{pkg_name}/#{pkg_name}_1.0-1_all.deb`

end

def publish_package(pkg_name)

  `curl -X POST -u#{$key} https://api.bintray.com/content/balaswecha/balaswecha-dev/#{pkg_name}/1.0-1/publish`

end

Dir.chdir('dist') do
  $videos.each do |video|
    pkg_name = video["name"].split('.').first
    Dir.chdir(pkg_name) do
      create_package(pkg_name)
      create_version(pkg_name)
      upload_package(pkg_name)
      publish_package(pkg_name)
    end
    puts "++++++++++++++++++++\nUploaded #{pkg_name}..\n+++++++++++++++++++++\n"
  end
  puts "Successfully uploaded All packages"
end
