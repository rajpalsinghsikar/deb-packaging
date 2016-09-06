#!/usr/bin/env ruby

require 'fileutils'

java_apps_data_file = './all_apps/java_apps.rb'
html_apps_data_file = './all_apps/html_apps.rb'
flash_apps_data_file = './all_apps/flash_apps.rb'

require java_apps_data_file
java_apps = ''
for i in 0..$apps.length()-1
  java_apps = java_apps + $apps[i]['name']+',';
end
require flash_apps_data_file
flash_apps = $apps.join(',');
puts flash_apps
require html_apps_data_file
html_apps = $apps.join(',')

all_apps = java_apps + flash_apps +','+html_apps;
puts all_apps

app = 'meta-package'

def generate_meta_files(app, version,all_apps)
  puts "Generating Deb files ..."
  Dir.mkdir('debian')
  Dir.chdir('debian') do
    generate_changelog(app)
    generate_control(app,all_apps)
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
  FILE
  File.write("#{app}.install", contents)
end

def generate_control(app,all_apps)
  contents = <<-FILE.gsub(/^ {4}/, '')
    Source: #{app}
    Maintainer: Balaswecha Team<balaswecha-dev-team@thoughtworks.com>
    Section: misc
    Priority: optional
    Standards-Version: 3.9.2
    Build-Depends: debhelper (>= 9)

    Package: #{app}
    Architecture: any
    Depends: ${shlibs:Depends}, ${misc:Depends}, #{all_apps}
    Description: #{app}
  FILE
  File.write('control', contents)
end

def generate_desktop(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    [Desktop Entry]
    Name=#{app}
    Comment=Simulation for #{app}
    Exec=#{app}
    Icon=#{app}
    Terminal=false
    Type=Application
    Categories=Simulations
  FILE

  File.write("#{app}.desktop",contents)
end


def generate_changelog(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
#{app} (1.0-1) UNRELEASED; urgency=low

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
  Dir.mkdir(app)
  Dir.chdir(app) do
    version = "1.0"
    Dir.mkdir("#{app}-#{version}")
    Dir.chdir("#{app}-#{version}") do
      generate_meta_files(app, version,all_apps)
      generate_deb
    end
  end
end