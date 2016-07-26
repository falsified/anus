#!/bin/bash
# gay mod/rip of several scripts for dnsmasq ad blocking
# mega adblock https://gist.github.com/OnlyInAmerica/75e200886e02e7562fa1
# yo mama

ad_file="/etc/dnsmasq.d/dnsmasq.adlist.conf"
temp_ad_file="/etc/dnsmasq.d/dnsmasq.adlist.conf.tmp"
temp_ad_file2="/etc/dnsmasq.d/dnsmasq.adlist.conf.inter"

rm /etc/dnsmasq.d/dnsmasq.adlist.conf.*

echo "Getting yoyo ad list..." # Approximately 2452 domains at the time of writing
curl -s -d mimetype=plaintext -d hostformat=unixhosts http://pgl.yoyo.org/adservers/serverlist.php? | sort > $temp_ad_file
echo "Getting winhelp2002 ad list..." # 12985 domains
curl -s http://winhelp2002.mvps.org/hosts.txt | grep -v "#" | grep -v "127.0.0.1" | sed '/^$/d' | sed 's/\ /\\ /g' | awk '{print $2}' | sort >> $temp_ad_file
echo "Getting adaway ad list..." # 445 domains
curl -s https://adaway.org/hosts.txt | grep -v "#" | grep -v "::1" | sed '/^$/d' | sed 's/\ /\\ /g' | awk '{print $2}' | grep -v '^\\' | grep -v '\\$' | sort >> $temp_ad_file
echo "Getting hosts-file ad list..." # 28050 domains
curl -s http://hosts-file.net/.%5Cad_servers.txt | grep -v "#" | grep -v "::1" | sed '/^$/d' | sed 's/\ /\\ /g' | awk '{print $2}' | grep -v '^\\' | grep -v '\\$' | sort >> $temp_ad_file
echo "Getting malwaredomainlist ad list..." # 1352 domains
curl -s http://www.malwaredomainlist.com/hostslist/hosts.txt | grep -v "#" | sed '/^$/d' | sed 's/\ /\\ /g' | awk '{print $3}' | grep -v '^\\' | grep -v '\\$' | sort >> $temp_ad_file
echo "Getting adblock.gjtech ad list..." # 696 domains
curl -s http://adblock.gjtech.net/?format=unix-hosts | grep -v "#" | sed '/^$/d' | sed 's/\ /\\ /g' | awk '{print $2}' | grep -v '^\\' | grep -v '\\$' | sort >> $temp_ad_file
echo "Getting someone who cares ad list..." # 10600
curl -s http://someonewhocares.org/hosts/hosts | grep -v "#" | sed '/^$/d' | sed 's/\ /\\ /g' | grep -v '^\\' | grep -v '\\$' | awk '{print $2}' | grep -v '^\\' | grep -v '\\$' | sort >> $temp_ad_file
echo "Getting Mother of All Ad Blocks list..." # 102168 domains!! Thanks Kacy
curl -A 'Mozilla/5.0 (X11; Linux x86_64; rv:30.0) Gecko/20100101 Firefox/30.0' -e http://forum.xda-developers.com/ http://adblock.mahakala.is/ | grep -v "#" | awk '{print $2}' | sort >> $temp_ad_file



if [ -f "$temp_ad_file" ]
then
	# Sort the aggregated results and remove any duplicates
	# Remove entries from the whitelist file if it exists at the root of the current user's home folder


        sed -i -e '/\.kat\.am/d' $temp_ad_file2
        sed -i -e '/\.amazon\.com/d' $temp_ad_file2
        sed -i -e '/\.microsoft\.com/d' $temp_ad_file2
        sed -i -e '/skype\.com/d' $temp_ad_file2


	echo "Removing duplicates and formatting the list of domains..."
	cat $temp_ad_file | sed $'s/\r$//' | sort | uniq | sed '/^$/d' | awk '{sub(/\r$/,""); print "address=/"$0"/0.0.0.0"}' > $temp_ad_file2



        sed -i -e '/\.kat\.am/d' $temp_ad_file2

        echo "address=/internalredirect.site/0.0.0.0" >> $temp_ad_file2


        mv $temp_ad_file2 $ad_file
        rm /etc/dnsmasq.d/dnsmasq.adlist.conf.*

	# Count how many domains/whitelists were added so it can be displayed to the user
	numberOfAdsBlocked=$(cat $ad_file | wc -l | sed 's/^[ \t]*//')
	echo "$numberOfAdsBlocked ad domains blocked."

else
        echo "Error building the ad list, please try again."
        exit
fi

systemctl restart dnsmasq.service
