#! /bin/bash
# run all the hackbox system monitor scripts to update graphs
for script in /usr/share/hackbox-system-monitor/scripts/*;do
	bash $script;
done;
