#! /bin/bash
########################################################################
# Animate the generated graphs for weekly and daily views
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
# Script should update every hour to regenerate these animations
########################################################################
# timeframes for generating the graphs
timeFrameList="day week";
# global path to munin files
muninPath=/var/cache/munin/www/localdomain/localhost.localdomain/;
animationDir="/var/cache/hackbox-system-monitor/animation/";
for timeFrame in $timeFrameList;do
	muninGraphs="entropy load cpu memory processes interrupts df diskstats_iops uptime users fail2ban lpstat";
	webpageUrl="/var/cache/hackbox-system-monitor/$timeFrame.html";
	for muninGraph in $muninGraphs;do
		tempFileName=$muninGraph-$timeFrame
		# if the graph exists then generate a animated gif for it
		if [ -e $muninPath$tempFileName.png ];then
			# create the animation directory to store images for animation
			mkdir -p $animationDir$tempFileName/
			# replace png with generated gif in webpage
			rpl -q "<img src='$tempFileName.png'" "<img src='$tempFileName.gif'" $webpageUrl
			# remove old images to keep the animation up to date
			if [ "$timeFrame" == "day" ];then
				#remove graphs older than 24 hours
				find $animationDir$tempFileName/ -type f -mtime +1 -delete
			elif [ "$timeFrame" == "week" ];then
				#remove graphs older than 1 week
				find $animationDir$tempFileName/ -type f -mtime +7 -delete
			fi
			# copy over the latest graph and regenerate the gif from the directory
			mkdir -p $animationDir$tempFileName/
			cp $muninPath$tempFileName.png $animationDir$tempFileName/$(date +%s).png
			# generate animated gif from the files in each directory
			convert -delay 20 -loop 0 $animationDir$tempFileName/*.png /var/cache/hackbox-system-monitor/$tempFileName.gif
		fi
	done
done
