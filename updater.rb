#!/usr/bin/env ruby

require 'fileutils'

BASE_URL="http://phet.colorado.edu/sims/html/"
apps = [
  "acid-base-solutions",
  "area-builder",
  "arithmetic",
  "balancing-act",
  "balancing-chemical-equations",
  "balloons-and-static-electricity",
  "beers-law-lab",
  "bending-light",
  "build-an-atom",
  "color-vision",
  "concentration",
  "energy-skate-park-basics",
  "faradays-law",
  "forces-and-motion-basics",
  "fraction-matcher",
  "friction",
  "graphing-lines",
  "gravity-force-lab",
  "hookes-law",
  "john-travoltage",
  "least-squares-regression",
  "molarity",
  "molecules-and-light",
  "molecule-shapes",
  "molecule-shapes-basics",
  "ohms-law",
  "ph-scale",
  "ph-scale-basics",
  "reactants-products-and-leftovers",
  "resistance-in-a-wire",
  "under-pressure",
  "wave-on-a-string"
]

def uri_for(app)
  "#{BASE_URL}/#{app}/latest/#{app}_en.html"
end

def download_app(app)
  `wget -nv #{uri_for(app)}`
end

def generate_deb_files(app)
  puts "Generating Deb files ..."
  FileUtils.rm_rf app
  Dir.mkdir(app)
  Dir.chdir(app) do
    Dir.mkdir('debian')
    Dir.chdir('debian') do
      generate_changelog(app)
      generate_control(app)
      generate_compat(app)
    end
  end
  puts ".. Done!"
end

def generate_control(app)
  contents = <<-FILE
    Source: #{app}
    Maintainer: Balaswecha Team<balaswecha-dev-team@thoughtworks.com>
    Section: misc
    Priority: optional
    Standards-Version: 3.9.2
    Build-Depends: debhelper (>= 9)

    Package: #{app}
    Architecture: any
    Depends: ${shlibs:Depends}, ${misc:Depends}
    Description: #{app}
    #{app} is an educational simulation.
  FILE
  File.write('control', contents)
end

def generate_changelog(app)
  contents = <<-FILE
    #{app} (1.0-1) UNRELEASED; urgency=low

     * Initial release. (Closes: #XXXXXX)

    -- Balaswecha Team <balaswecha-dev-team@thoughtworks.com>  #{Time.now.strftime '%a, %-d %b %Y %H:%M:%S %z'}
  FILE
  File.write('changelog', contents)
end

def generate_compat(app)
  File.write('compat', '9\n')
end

def generate_deb(app)
  download_app(app)
  generate_deb_files(app)
end

#apps = apps.take(1)
apps.each do |app|
  generate_deb(app)
end
