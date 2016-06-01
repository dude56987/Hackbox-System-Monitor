show:
	echo 'Run "make install" as root to install program!'
test:
	sudo bash /etc/cron.daily/hackbox-system-monitor-update
install: build
	sudo gdebi -n hackbox-system-monitor_UNSTABLE.deb
uninstall:
	sudo apt-get purge hackbox-system-monitor
installed-size:
	du -sx --exclude DEBIAN ./debian/
build: 
	sudo make build-deb;
build-deb:
	# build the directories inside the package
	mkdir -p debian;
	mkdir -p debian/DEBIAN;
	mkdir -p debian/usr;
	mkdir -p debian/usr/share/hackbox-system-monitor;
	mkdir -p debian/usr/share/hackbox-system-monitor/interfaces;
	mkdir -p debian/usr/share/hackbox-system-monitor/scripts;
	mkdir -p debian/etc;
	mkdir -p debian/etc/cron.daily/;
	mkdir -p debian/etc/apache2/;
	mkdir -p debian/etc/apache2/sites-enabled/;
	mkdir -p debian/etc/apache2/conf-enabled/;
	# copy over the scripts
	cp -v scripts/* debian/usr/share/hackbox-system-monitor/scripts/
	cp -v template.css debian/usr/share/hackbox-system-monitor/
	# copy over apache configs
	cp -v apacheConf/hackbox-system-monitor-ports.conf debian/etc/apache2/conf-enabled/
	cp -v apacheConf/hackbox-system-monitor-website.conf debian/etc/apache2/sites-enabled/
	# copy over the cron file that runs update scripts on the site
	cp -v hackbox-system-monitor-update.sh debian/etc/cron.daily/hackbox-system-monitor-update
	# make the cron script executable
	chmod +x debian/etc/cron.daily/hackbox-system-monitor-update
	# Create the md5sums file
	find ./debian/ -type f -print0 | xargs -0 md5sum > ./debian/DEBIAN/md5sums
	# cut filenames of extra junk
	sed -i.bak 's/\.\/debian\///g' ./debian/DEBIAN/md5sums
	sed -i.bak 's/\\n*DEBIAN*\\n//g' ./debian/DEBIAN/md5sums
	sed -i.bak 's/\\n*DEBIAN*//g' ./debian/DEBIAN/md5sums
	rm -v ./debian/DEBIAN/md5sums.bak
	# figure out the package size	
	du -sx --exclude DEBIAN ./debian/ > Installed-Size.txt
	# copy over package data
	cp -rv debdata/. debian/DEBIAN/
	# fix permissions in package
	chmod -Rv 775 debian/DEBIAN/
	chmod -Rv ugo+r debian/
	chmod -Rv go-w debian/
	chmod -Rv u+w debian/
	# build the package
	dpkg-deb --build debian
	cp -v debian.deb hackbox-system-monitor_UNSTABLE.deb
	rm -v debian.deb
	rm -rv debian
