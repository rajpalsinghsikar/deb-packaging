#!/usr/bin/env ruby

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
end

def generate_deb(app)
  download_app(app)
  generate_deb_files(app)
end

apps.each do |app|
  generate_deb(app)
end
