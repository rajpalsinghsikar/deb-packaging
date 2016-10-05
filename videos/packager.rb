#!/usr/bin/env ruby

require 'fileutils'
videos_meta_file = './videos.rb'

require videos_meta_file
puts $videos


def generate_meta_files(video, version)
  video_name = video["name"].split('.')[0]
  Dir.mkdir('debian')
  Dir.chdir('debian') do
    generate_changelog(video_name)
    generate_control(video_name)
    generate_compat()
    generate_copyright()
    generate_rules()
    generate_install(video)
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

def generate_install(video)
  contents = <<-FILE.gsub(/^ {4}/, '')
    #{video["name"]} var/lib/balaswecha/videos/#{video["subject"]}/
  FILE
  File.write("#{video["name"].split('.').first}.install", contents)
end

def generate_control(video)
  contents = <<-FILE.gsub(/^ {4}/, '')
    Source: #{video}
    Maintainer: Balaswecha Team<balaswecha-dev-team@thoughtworks.com>
    Section: misc
    Priority: optional
    Standards-Version: 3.9.2
    Build-Depends: debhelper (>= 9)

    Package: #{video}
    Architecture: all
    Depends: ${shlibs:Depends}, ${misc:Depends}
    Description: #{video}
  FILE
  File.write('control', contents)
end

def generate_changelog(video)
  contents = <<-FILE.gsub(/^ {4}/, '')
    #{video} (1.0-1) UNRELEASED; urgency=low

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
  $videos.each do |video|
    video_name = video["name"].split('.')[0];
    Dir.mkdir(video_name)
    Dir.chdir(video_name) do
      version = "1.0"
      Dir.mkdir("#{video_name}-#{version}")
      Dir.chdir("#{video_name}-#{version}") do
        puts "Building Debian package for #{video_name}"
        FileUtils.cp("../../../videos/#{video["subject"]}/#{video["name"]}",".") 
        generate_meta_files(video, version)
        generate_deb
        puts "Done!"
      end
    end
  end
end
