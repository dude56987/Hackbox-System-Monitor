#! /bin/bash
########################################################################
# Generate webpages for uptime information
# Copyright (C) 2016  Carl J Smith
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
########################################################################
# timeframes for generating the graphs
timeFrameList="day week month year";
# global path to munin files
muninPath=/var/cache/munin/www/localdomain/localhost.localdomain/;
# create the webpage directory if it does not exist
mkdir -p /var/cache/hackbox-system-monitor/
for timeFrame in $timeFrameList;do
	# set the webpage url
	webpageUrl="/var/cache/hackbox-system-monitor/uptime-$timeFrame.html";
	# touch the webpage
	touch $webpageUrl;
	# start building the generated webpage
	echo "<html><head>" > $webpageUrl;
	echo "<title>$(hostname) System Monitor</title>" >> $webpageUrl;
	echo "<style>" >> $webpageUrl
	cat /etc/hackbox-system-monitor/templates/template.css >> $webpageUrl;
	echo "</style><script>" >> $webpageUrl;
	cat /etc/hackbox-system-monitor/templates/template.js >> $webpageUrl;
	echo "</script><body>" >> $webpageUrl;
	echo "<div class='main'>" >> $webpageUrl;
	# generate the munin graphs
	echo "<h1>$(hostname) System Graphs</h1>" >> $webpageUrl;
	# generate the buttons
	echo "<hr /><br />" >> $webpageUrl;
	echo "<div class='buttons'>" >> $webpageUrl;
	echo "<a href='uptime-day.html'><span>Daily</span></a>" >> $webpageUrl;
	echo "<a href='uptime-week.html'><span>Weekly</span></a>" >> $webpageUrl;
	echo "<a href='uptime-month.html'><span>Monthly</span></a>" >> $webpageUrl;
	echo "<a href='uptime-year.html'><span>Yearly</span></a>" >> $webpageUrl;
	# create link to munin directory
	echo "<a href='www/'><span>Munin</span></a>" >> $webpageUrl;
	echo "</div>" >> $webpageUrl;
	echo "<br /><hr />" >> $webpageUrl;
	tempFileName=uptime-$timeFrame.png
	echo "<a style='width:100%' class='graph' href='$tempFileName'>" >> $webpageUrl;
	echo "<img style='width:100%;height:400px' src='$tempFileName' /></a>" >> $webpageUrl;

	echo "<h1>System shutdowns</h1>" >> $webpageUrl;
	echo "<hr />" >> $webpageUrl;
	echo "<pre>" >> $webpageUrl;
	last -f /var/log/wtmp.1 | grep wtmp | sed 's/wtmp.1 begins/System shutdowns since/g' >> $webpageUrl
	last -a -x | grep -v wtmp | grep shutdown >> $webpageUrl
	last -f /var/log/wtmp.1 -a -x | grep -v wtmp | grep shutdown >> $webpageUrl
	echo "</pre>" >> $webpageUrl

	echo "<h1>System reboots</h1>" >> $webpageUrl;
	echo "<hr />" >> $webpageUrl;
	echo "<pre>" >> $webpageUrl;
	last -f /var/log/wtmp.1 | grep wtmp | sed 's/wtmp.1 begins/System reboots since/g' >> $webpageUrl
	last -a -x | grep -v wtmp | grep reboot >> $webpageUrl
	last -f /var/log/wtmp.1 -a -x | grep -v wtmp | grep reboot >> $webpageUrl
	echo "</pre>" >> $webpageUrl

	echo "<h1>System crashes</h1>" >> $webpageUrl;
	echo "<hr />" >> $webpageUrl;
	echo "<pre>" >> $webpageUrl;
	last -f /var/log/wtmp.1 | grep wtmp | sed 's/wtmp.1 begins/System crashes since/g' >> $webpageUrl
	last -a -x | grep -v wtmp | grep crash >> $webpageUrl
	last -f /var/log/wtmp.1 -a -x | grep -v wtmp | grep crash >> $webpageUrl
	echo "</pre>" >> $webpageUrl

	echo "</body>" >> $webpageUrl
done
