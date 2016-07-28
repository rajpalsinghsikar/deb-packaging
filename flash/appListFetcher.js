"use strict";

var fs = require('fs');
var path = './flashApps.rb';

var webPage = require('webpage');
var page = webPage.create();

page.open('http://phet.colorado.edu/en/simulations', function (status) {

    var allAppsName = page.evaluate(function() {
        var javaApps = [];
        var all= document.getElementsByClassName('simulation-list-item');
        for(var i = 0; i<all.length;i++){
            if((all[i].innerHTML).indexOf('<span class="sim-display-badge sim-badge-flash"></span>')>-1){
                var selectedApps = all[i].getElementsByClassName('simulation-link')[0];
                javaApps.push(selectedApps.href.replace('http://phet.colorado.edu/en/simulation/legacy/','') +"\n")
            }
        }
        return javaApps;
    });
    console.log(allAppsName.length);
    fs.write(path, allAppsName.toString(), 'w');
    phantom.exit();
});
