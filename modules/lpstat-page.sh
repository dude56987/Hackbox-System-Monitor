#! /bin/bash
########################################################################
# Generate webpages for printer information
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
	webpageUrl="/var/cache/hackbox-system-monitor/lpstat-$timeFrame.html";
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
	echo "<a href='lpstat-day.html'><span>Daily</span></a>" >> $webpageUrl;
	echo "<a href='lpstat-week.html'><span>Weekly</span></a>" >> $webpageUrl;
	echo "<a href='lpstat-month.html'><span>Monthly</span></a>" >> $webpageUrl;
	echo "<a href='lpstat-year.html'><span>Yearly</span></a>" >> $webpageUrl;
	# create link to munin directory
	echo "<a href='www/'><span>Munin</span></a>" >> $webpageUrl;
	echo "</div>" >> $webpageUrl;
	echo "<br /><hr />" >> $webpageUrl;
	tempFileName=lpstat-$timeFrame.png
	echo "<a style='width:100%' class='graph' href='$tempFileName'>" >> $webpageUrl;
	echo "<img style='width:100%;height:400px' src='$tempFileName' /></a>" >> $webpageUrl;
	# generate the printer jobs list using the output of lpstat
	echo "<h1>Print Jobs</h1>" >> $webpageUrl;
	echo "<hr />" >> $webpageUrl;
	# set preformated text for the printer output
	echo "<pre>" >> $webpageUrl;
	# print all the previous and existing printer jobs
	lpstat -W all >> $webpageUrl
	echo "</pre>" >> $webpageUrl
	echo "</body>" >> $webpageUrl
done
