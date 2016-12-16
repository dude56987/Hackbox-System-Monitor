#! /bin/bash
########################################################################
# Generate webpages and vnstati graphs for hackbox-system-monitor
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
for timeFrame in $timeFrameList;do
	# create the webpage directory if it does not exist
	mkdir -p /var/cache/hackbox-system-monitor/
	# set the webpage url
	webpageUrl="/var/cache/hackbox-system-monitor/$timeFrame.html";
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
	echo "<a href='day.html'><span>Daily</span></a>" >> $webpageUrl;
	echo "<a href='week.html'><span>Weekly</span></a>" >> $webpageUrl;
	echo "<a href='month.html'><span>Monthly</span></a>" >> $webpageUrl;
	echo "<a href='year.html'><span>Yearly</span></a>" >> $webpageUrl;
	# link the munin webserver directory to a local folder here
	ln -s /var/cache/munin/www/ /var/cache/hackbox-system-monitor/
	# create link to munin directory
	echo "<a href='www/'><span>Munin</span></a>" >> $webpageUrl;
	echo "</div>" >> $webpageUrl;
	echo "<br /><hr />" >> $webpageUrl;
	echo "<div id='mainGraphs'>" >> $webpageUrl;
	# create array graphs to generate for munin
	muninGraphs="entropy load cpu memory processes interrupts df diskstats_iops uptime users fail2ban lpstat";
	for muninGraph in $muninGraphs;do
		tempFileName=$muninGraph-$timeFrame
		# if the graph exists then generate the html for it
		if [ -e $muninPath$tempFileName.png ];then
			ln -s $muninPath$tempFileName.png /var/cache/hackbox-system-monitor/$tempFileName.png
			if [ -e /var/cache/hackbox-system-monitor/$tempFileName.html ];then
				echo "<a class='graph' href='$tempFileName.html' >" >> $webpageUrl;
			else
				echo "<a class='graph' href='$tempFileName.png' >" >> $webpageUrl;
			fi
			echo "<img src='$tempFileName.png' /></a>" >> $webpageUrl;
		else
			# generate error codes in the HTML
			echo "<!-- Generating HTML for $tempFileName has failed! -->" >> $webpageUrl;
			echo "<!-- The approprate graph image could not be found! -->" >> $webpageUrl;
		fi
	done
	echo "</div>" >> $webpageUrl;
	# generate the network interfaces section
	echo "<div id='activeNetworkDevices'>" >> $webpageUrl;
	echo "<h1>Active Network Devices</h1>" >> $webpageUrl;
	echo "<hr />" >> $webpageUrl;
	# vnstat lists the devices in a directory that it stores
	# stats on so use that directory to generate the graphs
	for path in /var/lib/vnstat/*;do
		# clean up the path to get the device name
		device=$(echo $path|sed 's/\/var\/lib\/vnstat\///g')
		# generate the div that holds this interface's graphs
		echo "<div id='"$device"'>" >> $webpageUrl;
		# create a path to store generated graphs for each device
		devicePath=/var/cache/hackbox-system-monitor/$device
		# if network device has been used draw graphs
		echo $muninPath"if_"$device-$timeFrame".png"
		if [ -f $muninPath"if_"$device-$timeFrame".png" ];then
			# create the path if it does not exist
			mkdir -p $devicePath
			# generate graphs for the device
			vnstati -i $device -s -o $devicePath/summary.png;
			vnstati -i $device -h -o $devicePath/hourly.png;
			vnstati -i $device -m -o $devicePath/monthly.png;
			vnstati -i $device -t -o $devicePath/top.png;
			# create links to munin graphs for device
			muninGraphs="if_ if_err_";
			for muninGraph in $muninGraphs;do
				tempFileName=$muninGraph$device-$timeFrame.png
				if [ -e $muninPath$tempFileName ];then
					ln -s $muninPath$tempFileName /var/cache/hackbox-system-monitor/$tempFileName
					echo "<a class='graph' href='$tempFileName'>" >> $webpageUrl;
					echo "<img src='$tempFileName' /></a>" >> $webpageUrl;
				else
					# generate error codes in the html
					echo "<!-- Generating HTML for $tempFileName has failed! -->" >> $webpageUrl;
					echo "<!-- The approprate graph image could not be found! -->" >> $webpageUrl;
				fi
			done
			# create links to generated paths in webpage
			echo "<a class='graph' href='$device/summary.png'>" >> $webpageUrl
			echo "<img src='$device/summary.png' /></a>" >> $webpageUrl
			echo "<a class='graph' href='$device/hourly.png'>" >> $webpageUrl
			echo "<img src='$device/hourly.png' /></a>" >> $webpageUrl
			echo "<a class='graph' href='$device/monthly.png'>" >> $webpageUrl
			echo "<img src='$device/monthly.png' /></a>" >> $webpageUrl
			echo "<a class='graph' href='$device/top.png'>" >> $webpageUrl
			echo "<img src='$device/top.png' /></a>" >> $webpageUrl
		else
			errorMsg="if_"$device-$timeFrame".png"
			# generate error codes in the HTML
			echo "<!-- Generating HTML for $errorMsg has failed! -->" >> $webpageUrl;
			echo "<!-- The approprate graph image could not be found! -->" >> $webpageUrl;
		fi
		echo "</div>" >> $webpageUrl;
	done
	echo "</div>" >> $webpageUrl
	echo "</body>" >> $webpageUrl
	echo "</html>" >> $webpageUrl
done
# copy day to index
cp -v /var/cache/hackbox-system-monitor/day.html /var/cache/hackbox-system-monitor/index.html
