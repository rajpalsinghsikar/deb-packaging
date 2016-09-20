#!/usr/bin/env ruby

require 'fileutils'
apps_data_file= './apps.rb'


require apps_data_file
puts $apps

def uri_for(app)
  "#{app["jar_url"]}"
end

def icon_for(app)
   "#{app["icon_url"]}"
end

def download_app(app)
  `wget -nv #{uri_for(app)}`
end

def download_icon(app)
  `wget -nv -O #{app["name"]}.png #{icon_for(app)}`
end

def generate_tar(app, version)
  appWithVersion = "#{app["name"]}-#{version}"
  Dir.mkdir(appWithVersion)
  Dir.chdir(appWithVersion) do
    download_app(app)
    download_icon(app)
    generate_desktop(app)
    generate_bin(app)
  end
  tar_filename = "#{app["name"]}_#{version}.orig.tar.gz"
  `tar czf #{tar_filename} #{appWithVersion}`
  FileUtils.rm_rf(appWithVersion)
  tar_filename
end

def extract_tar(filename)
  `tar xzf #{filename}`
end

def generate_meta_files(app, version)
  puts "Generating Deb files ..."
  Dir.mkdir('debian')
  Dir.chdir('debian') do
    generate_changelog(app)
    generate_control(app)
    generate_compat()
    generate_copyright()
    generate_rules()
    generate_install(app)
    generate_format()
  end
  puts ".. Done!"
end

def generate_copyright()
  contents = <<-FILE.gsub(/^ {4}/, '')
    GPL V3
  FILE
  File.write('copyright', contents)
end

def generate_rules()
  contents = <<-FILE.gsub(/^ {4}/, '')
    #!/usr/bin/make -f
    %:
    	dh $@
    override_dh_usrlocal:
  FILE
  File.write("rules", contents)
end

def generate_format()
  Dir.mkdir('source')
  Dir.chdir('source') do
    contents = <<-FILE.gsub(/^ {6}/, '')
      3.0 (quilt)
    FILE
    File.write('format', contents)
  end
end

def generate_install(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    #{app["name"]}_en.jar usr/lib/balaswecha/java
    #{app["name"]}.desktop usr/share/applications
    #{app["name"]}.png usr/share/icons/hicolor/128x128/apps
    #{app["name"]} usr/bin
  FILE
  File.write("#{app["name"]}.install", contents)
end

def generate_control(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    Source: #{app["name"]}
    Maintainer: Balaswecha Team<balaswecha-dev-team@thoughtworks.com>
    Section: misc
    Priority: optional
    Standards-Version: 3.9.2
    Build-Depends: debhelper (>= 9)

    Package: #{app["name"]}
    Architecture: all
    Depends: ${shlibs:Depends}, ${misc:Depends}, default-jre
    Description: #{app["desc"]}
  FILE
  File.write('control', contents)
end

def generate_desktop(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    [Desktop Entry]
    Name=#{app["launcher_name"]}
    Comment=Simulation for #{app["name"]}
    Exec=#{app["name"]}
    Icon=#{app["name"]}
    Terminal=false
    Type=Application
    Categories=Simulations
  FILE

  File.write("#{app["name"]}.desktop",contents)
end

def generate_bin(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    java -jar /usr/lib/balaswecha/java/#{app["name"]}_en.jar
  FILE
  File.write(app["name"], contents)
end

def generate_changelog(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    #{app["name"]} (1.0-1) UNRELEASED; urgency=low

      * Initial release. (Closes: #XXXXX)

     -- Balaswecha Team <balaswecha-dev-team@thoughtworks.com>  #{Time.now.strftime '%a, %-d %b %Y %H:%M:%S %z'}
  FILE
  File.write('changelog', contents)
end

def generate_compat()
  File.write('compat', "9\n")
end

def generate_deb
  `debuild -i -us -uc -b`
end

FileUtils.rm_rf 'dist'
Dir.mkdir('dist')
Dir.chdir('dist') do
  #apps = apps.take(1)
  $apps.each do |app|
    Dir.mkdir(app["name"])
    Dir.chdir(app["name"]) do
      version = "1.0"
      tar_filename = generate_tar(app, version)
      extract_tar(tar_filename)
      Dir.chdir("#{app["name"]}-#{version}") do
        generate_meta_files(app, version)
        generate_deb
      end
    end
  end
end
