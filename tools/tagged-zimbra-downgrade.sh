#!/bin/bash

LDAP_DOWNGRADE_FIX_DIR="/opt/zimbra/conf/scripts/LDAP_DOWNGRADE_FIX"

function usage {

  $0

}

function fixBorkedLdap {

  mkdir -p ${LDAP_DOWNGRADE_FIX_DIR}
  /opt/zimbra/libexec/zmslapcat ${LDAP_DOWNGRADE_FIX_DIR}
  echo 'You can ignore xxxxxxx UNKNOWN attributeDescription "ZIMBRAxxxxxxxxxxxx" inserted. messages from above.'

  # Actual fix
  cp ${LDAP_DOWNGRADE_FIX_DIR}/ldap.bak ${LDAP_DOWNGRADE_FIX_DIR}/ldap_TO-BE-FIXED.bak
  cat ${LDAP_DOWNGRADE_FIX_DIR}/ldap_TO-BE-FIXED.bak | grep -v -E '^ZIMBRA' > ${LDAP_DOWNGRADE_FIX_DIR}/ldap.bak

  # Extra dumps not actually needed
  /opt/zimbra/libexec/zmslapcat -c ${LDAP_DOWNGRADE_FIX_DIR}
  /opt/zimbra/libexec/zmslapcat -a ${LDAP_DOWNGRADE_FIX_DIR}

  # Stop ldap and remove old ldap database
  ldap stop

  mv /opt/zimbra/data/ldap/mdb /opt/zimbra/data/ldap/mdb.old_LDAP_DOWNGRADE_FIX
  mkdir -p /opt/zimbra/data/ldap/mdb/db

  # Import sanitized ldap dump
  /opt/zimbra/libexec/zmslapadd ${LDAP_DOWNGRADE_FIX_DIR}/ldap.bak
}

if [ "x$(id -u -n)" != "xzimbra" ]; then
  echo "Please run as ZIMBRA user"
  echo "Exiting..."
  exit 1
fi

###

source ~/bin/zmshutil
zmsetvars

read -p "This will restart Zimbra. Are you sure?" -r restart_choice
if [[ $restart_choice =~ ^[Yy]$ ]] ; then
  echo "Processing..."
  fixBorkedLdap
  echo "...Done."
  echo "Now starting Zimbra..."
  ldap stop
  zmcontrol start
else
  echo "Aborted by the user."
fi
