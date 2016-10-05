#!/usr/bin/env ruby

require 'fileutils'

app = 'balaswecha-skin'

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
    generate_postinst()
    generate_format()
  end
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

def generate_control(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    Source: #{app}
    Maintainer: Balaswecha Team<balaswecha-dev-team@thoughtworks.com>
    Section: misc
    Priority: optional
    Standards-Version: 3.9.2
    Build-Depends: debhelper (>= 9)

    Package: #{app}
    Architecture: all
    Depends: ${shlibs:Depends}, ${misc:Depends}
    Description: BalaSwecha Icon and Wallpaper Pack
  FILE
  File.write('control', contents)
end

def generate_install(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    wallpapers/balaswecha-dark.png usr/share/backgrounds/
    wallpapers/balaswecha-default.jpg usr/share/backgrounds/

    desktop_files/biology.desktop usr/share/applications/
    desktop_files/chemistry.desktop usr/share/applications/
    desktop_files/physics.desktop usr/share/applications/
    desktop_files/english.desktop usr/share/applications/
    desktop_files/maths.desktop usr/share/applications/
    desktop_files/social.desktop usr/share/applications/

    icons/pencilbox-biology.png usr/share/icons/
    icons/pencilbox-chemistry.png usr/share/icons/
    icons/pencilbox-physics.png usr/share/icons/
    icons/pencilbox-english.png usr/share/icons/
    icons/pencilbox-maths.png usr/share/icons/
    icons/pencilbox-social.png usr/share/icons/

    balaswecha-skin usr/bin/
  FILE
  File.write("#{app}.install", contents)
end

def generate_postinst()
  contents = <<-FILE.gsub(/^ {4}/, '')
    #!/usr/bin/env bash

    echo "$(tput setaf 1)$(tput setab 8)To apply this theme, you need to run balaswecha-skin$(tput sgr 0)"
    exit 0
  FILE
  File.write('postinst', contents)
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
  puts "Done!"
end

FileUtils.rm_rf 'dist'
Dir.mkdir('dist')
Dir.chdir('dist') do
  version = "1.0"
  Dir.mkdir("#{app}-#{version}")
  FileUtils.cp_r("../assets/wallpapers","#{app}-#{version}/")
  FileUtils.cp_r("../assets/icons","#{app}-#{version}/")
  FileUtils.cp_r("../assets/desktop_files","#{app}-#{version}/")
  FileUtils.cp("../assets/balaswecha-skin","#{app}-#{version}/")
  Dir.chdir("#{app}-#{version}") do
    generate_meta_files(app, version)
    generate_deb
  end
end
