#!/bin/sh
I=`b mgmt | awk '{print $2}'`
IP=`whoami`@${I}
awk '{gsub("Host Processor Superuser","'${IP}'"); print }' ~/.ssh/identity.pub > ~/.ssh/identity.pub.${IP}

for H in $*; do
	if [ "${H}" == "${I}" ]; then continue ; fi
	scp ~/.ssh/identity.pub.${IP} ${H}:~/.ssh/identity.pub.${IP}
	scp /var/tmp/sshkswap.sh ${H}:/var/tmp/sshkswap.sh
	ssh ${H} sh /var/tmp/sshkswap.sh $*
	done
	
for F in ~/.ssh/identity.pub*; do
	cat ${F} >> ~/.ssh/authorized_keys
	done

sort -u ~/.ssh/authorized_keys > ~/.ssh/authorized_keys.tmp
cp -f ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys
chmod a=r,u+w ~/.ssh/authorized_keys


