#!/bin/bash
#AUTHOR: Daniele Volpe

echo > domainsChaos.txt
while IFS= read -r line; do           #read each line of the file domains2.txt
	if dig -t ns $line | grep -q 'CNAME'; then
		continue
	fi
	dig -t ns $line +short | tee nameservers.txt   #save the nameservers of the domain $line in the file nameservers.txt    
	while IFS= read -r i; do
		if [[ $i == *"aws"* || $i == *"cloudflare"* || $i == *"domaincontrol"* || $i == *"markmonitor"* || $i == *"akam"* || $i == *"google"* || $i == *"mastercard"* || $i == *"portsdns"* || $i == *"spotify"* ]]; then
  			continue
		fi
		echo "This is the Nameserver that we will query: $i for the domain $line" | tee -a domainsChaos.txt
		echo "version.bind-->" | tee -a domainsChaos.txt
		value=$(dig -t txt -c chaos version.bind @$i +short | tee -a domainsChaos.txt)
		if [[ $value == *'"'* ]]; then              #all the responses start with "
			echo "hostname.bind-->" | tee -a domainsChaos.txt
			dig -t txt -c chaos hostname.bind @$i +short | tee -a domainsChaos.txt
			echo "authors.bind-->" | tee -a domainsChaos.txt
			dig -t txt -c chaos authors.bind @$i +short | tee -a domainsChaos.txt
			echo "id.server-->" | tee -a domainsChaos.txt
			dig -t txt -c chaos id.server @$i +short | tee -a domainsChaos.txt
		fi
	done < nameservers.txt	
done < domains2.txt
