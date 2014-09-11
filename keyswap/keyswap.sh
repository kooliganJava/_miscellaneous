#!/bin/bash
# keyswap is meant to generate new ssh keys for the BigIP and SCCP
# and exchange them so that communication may continue
# copyright 2003-2005 F5 Networks, Inc.
#
# step 1:
#  machine creates new keys for host and root in tmp area
# step 2:
#  machine uses existing keys to copy the newly generated public keys into
#  a temporary area of the remote machine.
# step 3:
#  machine issues an ssh command to start the remote copy
#  machine does a local copy to overwrite the old keys with new.
# Done.

# TODO, future tasks
# 1) make keysize an argument.
# 2) make personal and host keys arguments so that you don't have to update all
#    similarly, make arguments so you an synch keys without making new ones.
#
BIGIP_IP="127.2.0.2"
SCCP_IP="127.2.0.1"

# create a temporary directory
mktempdir() {
  local tmpdir
  # create a temporary directory and return its name.
  if [ -x /bin/mktemp ] ; then
    tmpdir=`mktemp -d /tmp/ksXXXXXX`
  else
    rm -rf /tmp/ks
    mkdir /tmp/ks
    tmpdir=/tmp/ks
  fi
  echo ${tmpdir}
}

# restart sshd
restartsshd() {
  # attempt to get sshd to reload it's config
  if [ -f /var/run/sshd.pid ] ; then
    kill -HUP `cat /var/run/sshd.pid`
    return 0
  fi
  # otherwise, don't really know what to do, try killall
  killall -q -HUP sshd
}

usage() {
  echo "new.keyswap.sh <hostname> -- create new local ssh keys and update <hostname>"
  exit 0
}

# check that all is well, if not return an error string
checkalliswell() {
  # TODO invent some checks...
  return 0
  echo "gahhh, error!!!"
  return 1
}

# check to make sure all the lilnkx
check_links() {
  local -a src tgt
  local target i

  src=(/root/.ssh/authorized_keys /root/.ssh/identity /root/.ssh/identity.pub /root/.ssh/known_hosts /config/ssh/ssh_host_dsa_key /config/ssh/ssh_host_dsa_key.pub /config/ssh/ssh_host_key /config/ssh/ssh_host_key.pub /config/ssh/ssh_host_rsa_key /config/ssh/ssh_host_rsa_key.pub)
  tgt=(/var/ssh/root/authorized_keys /var/ssh/root/identity /var/ssh/root/identity.pub /var/ssh/root/known_hosts /var/ssh/ssh_host_dsa_key /var/ssh/ssh_host_dsa_key.pub /var/ssh/ssh_host_key /var/ssh/ssh_host_key.pub /var/ssh/ssh_host_rsa_key /var/ssh/ssh_host_rsa_key.pub)

  i=0
  for x in ${src[*]} ; do
    #echo "checking symlink $x -> ${tgt[$i]}"
    target=`readlink $x`
    if [ $? -ne 0 -o "X$target" != "X${tgt[$i]}" ] ; then
      echo "repairing link for $x -> ${tgt[$i]}"
      ln -sf ${tgt[$i]} $x
      if [ $? -ne 0 ] ; then
        echo "cannot make a symlink for $x -> ${tgt[$i]}"
      fi
    fi
    (( i = i + 1 ))
  done
}


# create ssh keys
createsshkeys() {

  local tmpdir realdir roottop sccp hostname username identity

  tmpdir=$1
  if [ ! -d ${tmpdir} ] ; then echo "$1 is not a directory"; return 1; fi
  hostname=`hostname`
  if ifconfig | grep -q $SCCP_IP ; then
    username="SCCP Superuser"
    identity=id_rsa
  else
    username="Host Processor Superuser"
    identity=identity
  fi

  if ifconfig | grep -q $SCCP_IP ; then
    realdir="/etc/ssh/"
    roottop="/root/.ssh"
    identity=id_rsa
    sccp=TRUE
  else
    realdir="/var/ssh/"
    roottop="/var/ssh/root"
    identity=identity
    sccp=
  fi

  # generate a new root identity key.
  # only if none currently exists
  if [ ! -f ${roottop}/${identity} ] ; then
  	echo "New root key is required but this script has been modified to use existing keys only."
  	#ssh-keygen -q -f ${tmpdir}/${identity} -t rsa -b 1024 -N "" -C "$username"
  	#if [ $? -ne 0 ] ; then echo "can't create host key"; return 1; fi
  else
  	cp -f ${roottop}/${identity}     ${tmpdir}/${identity}
  	cp -f ${roottop}/${identity}.pub ${tmpdir}/${identity}.pub
  fi


  # generate new host keys
  # only if none currently exists
  if [ ! -f ${realdir}/ssh_host_key ] ; then
  	echo "New root host rsa1 is required but this script has been modified to use existing keys only."
  	#ssh-keygen -q -f ${tmpdir}/ssh_host_key -t rsa1 -b1024 -N "" -C "$hostname"
  	#if [ $? -ne 0 ] ; then echo "can't create rsa1 key"; return 1; fi
  else
  	cp -f ${realdir}/ssh_host_key     ${tmpdir}/ssh_host_key
  	cp -f ${realdir}/ssh_host_key.pub ${tmpdir}/ssh_host_key.pub
  fi
  if [ ! -f ${realdir}/ssh_host_rsa_key ] ; then
  	echo "New host rsa key is required but this script has been modified to use existing keys only."
  	#ssh-keygen -q -f ${tmpdir}/ssh_host_rsa_key -t rsa -b1024 -N "" -C "$hostname"
  	#if [ $? -ne 0 ] ; then echo "can't create rsa2 key"; return 1; fi
  else
  	cp -f ${realdir}/ssh_host_rsa_key     ${tmpdir}/ssh_host_rsa_key
  	cp -f ${realdir}/ssh_host_rsa_key.pub ${tmpdir}/ssh_host_rsa_key.pub
  fi
  if [ ! -f ${realdir}/ssh_host_dsa_key ] ; then
  	echo "New host dsa  key is required but this script has been modified to use existing keys only."
  	#ssh-keygen -q -f ${tmpdir}/ssh_host_dsa_key -t dsa -b1024 -N "" -C "$hostname"
  	#if [ $? -ne 0 ] ; then echo "can't create dsa2 key"; return 1; fi
  else
  	cp -f ${realdir}/ssh_host_dsa_key     ${tmpdir}/ssh_host_dsa_key
  	cp -f ${realdir}/ssh_host_dsa_key.pub ${tmpdir}/ssh_host_dsa_key.pub
  fi
}

# commit local ssh keys
commitprivatekeys() {
  local tmpdir realdir roottop hostname identity sccp
  tmpdir=$1
  if [ ! -d ${tmpdir} ] ; then echo "$1 is not a directory"; return 1; fi

  # sccp and host store ssh configs in different places
  hostname=`hostname`
  if ifconfig | grep -q $SCCP_IP ; then
    realdir="/etc/ssh/"
    roottop="/root/.ssh"
    identity=id_rsa
    sccp=TRUE
  else
    realdir="/var/ssh/"
    roottop="/var/ssh/root"
    identity=identity
    sccp=
  fi
  # root identity
  cp -f ${tmpdir}/${identity} ${roottop}/
  cp -f ${tmpdir}/${identity}.pub ${roottop}/
  # SSH v1 host key
  cp -f ${tmpdir}/ssh_host_key ${realdir}
  cp -f ${tmpdir}/ssh_host_key.pub ${realdir}
  # SSH v2 rsa
  cp -f ${tmpdir}/ssh_host_rsa_key ${realdir}
  cp -f ${tmpdir}/ssh_host_rsa_key.pub ${realdir}/
  # SSH v2 dsa
  cp -f ${tmpdir}/ssh_host_dsa_key ${realdir}/
  cp -f ${tmpdir}/ssh_host_dsa_key.pub ${realdir}/

  # finally, on the sccp we need to write the keys to the nv
  if [ "${sccp}" ] ; then
      tar czfP /boot/nvfiles.tgz /etc/nvfiles.manifest -T /etc/nvfiles.manifest
  fi

}

startswap() {
  local remotehost errmsg tmpdir remotetmpdir onlylocal trycount

  onlylocal=0

  # make sure we can communicate to remote host
  if ifconfig | grep -q $SCCP_IP ; then
    remotehost=$BIGIP_IP
  else
    remotehost=$SCCP_IP
  fi
  ping -c 1 $remotehost >/dev/null 2>/dev/null
  if [ $? -ne 0 ] ; then
    onlylocal=1
  else
    scp /usr/bin/new.keyswap.sh $remotehost:/usr/bin
    if [ $? -ne 0 ] ; then
      echo "can't copy new.keyswap.sh to remote host, trying to sync anyway..."
    fi
    errmsg=`ssh $remotehost "new.keyswap.sh -check 2> /dev/null"`
    if [ $? -ne 0 ] ; then
      echo "can't ssh to $remotehost(${errmsg})"
      return 1
    fi
  fi

  # step0:
  # if we're on the host, make certain that the symlinks are set up correctly
  if [ "X$remotehost" = "X$SCCP_IP" ] ; then
    check_links
  fi

  # step1:
  # if /tmp/newsshkeys exists, we are being invoked with already existing
  # keys and we should read those.  We'll also append the non-sccp entries
  # from that directory onto our known-good known_hosts and authorized_keys
  # note that things are hardcoded here because this only happens on the host
  if [ -f /tmp/newsshkeys/ssh_host_key ] ; then
      tmpdir=/tmp/newsshkeys
#      grep -v "SCCP Superuser" /tmp/newsshkeys/authorized_keys >> /var/ssh/root/authorized_keys
#      grep -v "sccp,127.2.0.1" /tmp/newsshkeys/known_hosts >> /var/ssh/root/known_hosts
  else
  #if keys already exist, then we will use them
      tmpdir=$(mktempdir)
      createsshkeys ${tmpdir}
      if [ $? -ne 0 ] ; then echo "can't create ssh keys"; return 1; fi
  fi

  if [ $onlylocal -eq 0 ] ; then
    # step2:
    # create a temporary area on the remote machine.
    remotetmpdir=`ssh $remotehost "new.keyswap.sh -mktmpdir"`
    # copy the public keys over there.
    scp ${tmpdir}/id*.pub ${tmpdir}/ssh_host_key.pub ${tmpdir}/ssh_host_rsa_key.pub ${tmpdir}/ssh_host_dsa_key.pub ${remotehost}:${remotetmpdir}
    if [ $? -ne 0 ] ; then echo "can't scp pubkeys to $remotehost"; return 1; fi

    # step 3:
    # first check with remote machine to see that he got all the files.
    errmsg=`ssh $remotehost "new.keyswap.sh -checkkeys ${remotetmpdir}"`
    if [ $? -ne 0 ] ; then echo "can't ssh to $remotehost to check dir(${errmsg})"; return 1; fi

    # now commit the keys
    errmsg=`ssh $remotehost "new.keyswap.sh -commitkeys ${remotetmpdir}"`
    if [ $? -ne 0 ] ; then echo "can't ssh to $remotehost commit dir(${errmsg})"; return 1; fi
  fi

  # now we commit our own private keys
  $(commitprivatekeys ${tmpdir});

  # restart sshd
  $(restartsshd );

  # and clean up the tmpdir (or /tmp/newsshkeys dir)
  rm -rf ${tmpdir}
}

checkpublickeys() {
  local tmpdir

  tmpdir=$1
  if [ "$tmpdir" == "" ] ; then echo "${tmpdir} doesn't exist"; return 1; fi

  # check and make sure all files exist so we could commit them
  if [ -f ${tmpdir}/ssh_host_key.pub -a -f ${tmpdir}/ssh_host_rsa_key.pub -a -f ${tmpdir}/ssh_host_dsa_key.pub ] ; then
    :
  else
    echo "Not all files exist"
    return 1
  fi

  # TODO, check and make sure they are public key files.
  # TODO, maybe check permissions on the files?
  return 0
}

commitpublickeys() {
  local tmpdir hostname otherhostnames roottop sccp

  tmpdir=$1
  if [ "$tmpdir" == "" ] ; then echo "${tmpdir} doesn't exist"; return 1; fi
  hostname=`hostname`
  #get the other hosts certificate name and possible hostnames
  if ifconfig | grep -q $SCCP_IP ; then
    username="Host Processor Superuser"
    otherhostnames="host,$BIGIP_IP "
    roottop="/root/.ssh"
    identity=identity.pub
    sccp=TRUE
  else
    username="SCCP Superuser"
    otherhostnames="sccp,$SCCP_IP "
    roottop="/var/ssh/root"
    identity=id_rsa.pub
    sccp=
  fi

  # presumably we've already done a check, so we're going to just commit
  # TODO -- back up the old host keys under a new name so we can roll back
  #      -- probably should make sure f5 keys are always around.
  # TODO -- error checking.

  # root identity
  rm -f ${roottop}/authorized_keys.tmp
  # remove the old identity from the authorized_keys file, and then add new
  # grep -v Superuser ${roottop}/authorized_keys > ${roottop}/authorized_keys.tmp
  cat ${tmpdir}/${identity} >> ${roottop}/authorized_keys.tmp
  mv -f ${roottop}/authorized_keys.tmp ${roottop}/authorized_keys

  # clean up the known_hosts files, too.
  rm -f ${roottop}/known_hosts.tmp
  # grep -v "${otherhostnames}" ${roottop}/known_hosts > ${roottop}/known_hosts.tmp
  # SSH v1 host key
  echo -n "${otherhostnames}" >> ${roottop}/known_hosts.tmp
  cat ${tmpdir}/ssh_host_key.pub >> ${roottop}/known_hosts.tmp
  # SSH v2 rsa
  echo -n "${otherhostnames}" >> ${roottop}/known_hosts.tmp
  cat ${tmpdir}/ssh_host_rsa_key.pub >> ${roottop}/known_hosts.tmp
  # SSH v2 dsa
  echo -n "${otherhostnames}" >> ${roottop}/known_hosts.tmp
  cat ${tmpdir}/ssh_host_dsa_key.pub >> ${roottop}/known_hosts.tmp
  mv -f ${roottop}/known_hosts.tmp ${roottop}/known_hosts

  # clean up the tmpdir
  rm -rf ${tmpdir}

  # finally, on the sccp we need to write the keys to the nv
  if [ "${sccp}" ] ; then
      tar czfP /boot/nvfiles. /etc/nvfiles.manifest -T /etc/nvfiles.manifest
  fi

  return 0
}

# -=-=-=-=-=-=-=-=-=-=- main script
case $1 in
  -check) rsts=$(checkalliswell );;
  -mktmpdir) echo $(mktempdir );;
  -checkkeys) rsts=$(checkpublickeys $2);;
  -commitkeys) rsts=$(commitpublickeys $2);;
  sccp|host|other) rsts=$(startswap $1 $2);;
  *) echo $(usage );;
esac
if [ $? -ne 0 ] ; then echo "$rsts"; exit 1; fi
