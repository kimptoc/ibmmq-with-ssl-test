#!/bin/bash
# -*- mode: sh -*-
# © Copyright IBM Corporation 2017
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

configure_os_user()
{
  # The UID of the user to configure
  local -r ID_NUM=$1
  # The group ID of the user to configure
  local -r GROUP_NUM=$2
  # Name of environment variable containing the user name
  local -r USER_VAR=$3
  # Name of environment variable containing the password
  local -r PASSWORD=$4
  # Home directory for the user
  local -r HOME=$5
  # Determine the login name of the user (assuming it exists already)
  local -r LOGIN=$(getent passwd ${ID_NUM} | cut -f1 -d:)
  if [ -z ${!USER_VAR+x} ]; then
    # MQ_CLIENT_USER is unset
    if id --user ${ID_NUM}; then
      userdel --force --remove ${LOGIN} >/dev/null 2>&1
    fi
  else
    # MQ_CLIENT_USER is set
    if id --user ${ID_NUM}; then
      # Modify the existing user
      usermod -l ${!USER_VAR} ${LOGIN}
    else
      useradd --uid ${ID_NUM} --gid ${GROUP_NUM} --home ${HOME} ${!USER_VAR}
    fi

    # Change the user's password (if set)
    if [ ! "${!PASSWORD}" == "" ]; then
      echo ${!USER_VAR}:${!PASSWORD} | chpasswd
    fi
  fi
}

configure_tls()
{
  local -r PASSPHRASE=${MQ_TLS_PASSPHRASE}
  local -r LOCATION=${MQ_TLS_KEYSTORE}

  if [ ! -e ${LOCATION} ]; then
    echo "Error: The key store '${LOCATION}' referenced in MQ_TLS_KEYSTORE does not exist"
    exit 1
  fi

  keystore_created=false
  # Create keystore
  if [ ! -e "/tmp/tlsTemp/key.kdb" ]; then
    # Keystore does not exist
    runmqakm -keydb -create -db /tmp/tlsTemp/key.kdb -pw ${PASSPHRASE} -stash
    keystore_created=true
  fi

  # Create stash file
  if [ ! -e "/tmp/tlsTemp/key.sth" ]; then
    # No stash file, so create it
    runmqakm -keydb -stashpw -db /tmp/tlsTemp/key.kdb -pw ${PASSPHRASE}
  fi

  # Import certificate
  if [ "${keystore_created}" == "true" ]; then
    runmqakm -cert -import -file ${LOCATION} -pw ${PASSPHRASE} -target /tmp/tlsTemp/key.kdb -target_pw ${PASSPHRASE}

      # Find certificate to rename it to something MQ can use
      CERT=`runmqakm -cert -list -db /tmp/tlsTemp/key.kdb -pw ${PASSPHRASE} | egrep -m 1 "^\\**-"`
      CERTL=`echo ${CERT} | sed -e s/^\\**-//`
      CERTL=${CERTL:1}
      echo "Using certificate with label ${CERTL}"

      # Rename certificate
      runmqakm -cert -rename -db /tmp/tlsTemp/key.kdb -pw ${PASSPHRASE} -label "${CERTL}" -new_label queuemanagercertificate

      # Now copy the key files
      chown mqm:mqm /tmp/tlsTemp/key.*
      chmod 640 /tmp/tlsTemp/key.*
      su -c "cp -PTv /tmp/tlsTemp/key.kdb ${DATA_PATH}/qmgrs/$1/ssl/key.kdb" -l mqm
      su -c "cp -PTv /tmp/tlsTemp/key.sth ${DATA_PATH}/qmgrs/$1/ssl/key.sth" -l mqm

  fi

  # Set up Dev default MQ objects
  # Make channel TLS CHANNEL
  # Create SSLPEERMAP Channel Authentication record
  if [ "${MQ_DEV}" == "true" ]; then
    su -l mqm -c "echo \"ALTER CHANNEL('DEV.APP.SVRCONN') CHLTYPE(SVRCONN) SSLCIPH(TLS_RSA_WITH_AES_128_CBC_SHA) SSLCAUTH(OPTIONAL)\" | runmqsc $1"
    su -l mqm -c "echo \"ALTER CHANNEL('DEV.ADMIN.SVRCONN') CHLTYPE(SVRCONN) SSLCIPH(TLS_RSA_WITH_AES_128_CBC_SHA) SSLCAUTH(OPTIONAL)\" | runmqsc $1"
    su -l mqm -c "echo \"ALTER CHANNEL('DEV.SSLCAUTH.SVRCONN') CHLTYPE(SVRCONN) SSLCIPH(TLS_RSA_WITH_AES_128_CBC_SHA) SSLCAUTH(REQUIRED)\" | runmqsc $1"
#    su -l mqm -c "echo \"ALTER CHANNEL('DEV.APP.SVRCONN') CHLTYPE(SVRCONN) SSLCIPH(TLS_RSA_WITH_AES_256_GCM_SHA384) SSLCAUTH(OPTIONAL)\" | runmqsc $1"
#    su -l mqm -c "echo \"ALTER CHANNEL('DEV.ADMIN.SVRCONN') CHLTYPE(SVRCONN) SSLCIPH(TLS_RSA_WITH_AES_256_GCM_SHA384) SSLCAUTH(OPTIONAL)\" | runmqsc $1"
#    su -l mqm -c "echo \"ALTER CHANNEL('DEV.SSLCAUTH.SVRCONN') CHLTYPE(SVRCONN) SSLCIPH(TLS_RSA_WITH_AES_256_GCM_SHA384) SSLCAUTH(REQUIRED)\" | runmqsc $1"
  fi
}

echo "============================================================================================================"
echo "Setting up SSL certs/keystore - at runtime, so that we can put the keystore in a host dir, if mounted"
mkdir -p /etc/mqcerts
cd /etc/mqcerts

if [ ! -e "/etc/mqcerts/keystore.jks" ]; then

    openssl req -batch -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem

    echo "x" >openssl.params
    echo "x" >>openssl.params

    openssl pkcs12 -export -password file:openssl.params  -in cert.pem -inkey key.pem  -out keystore.p12 -name myAlias

    echo "Convert pkcs12 keystore to jks for Java clients"

    ls -ltr /etc/mqcerts

    /opt/mqm/java/jre64/jre/bin/keytool -importkeystore -noprompt -srckeystore /etc/mqcerts/keystore.p12 -srcstoretype pkcs12 -srcalias myAlias -srcstorepass x -destkeystore /etc/mqcerts/keystore.jks -deststoretype jks -deststorepass ABCDEF -destalias myAlias

    echo "keytool return code $?"

    ls -ltr /etc/mqcerts

    /opt/mqm/java/jre64/jre/bin/keytool -list -keystore /etc/mqcerts/keystore.jks -noprompt -storepass ABCDEF

else
  echo "Java keystore file exists /etc/mqcerts/keystore.jks - so assume its good to use"
    ls -ltr /etc/mqcerts
fi
export MQ_TLS_KEYSTORE=/etc/mqcerts/keystore.p12
export MQ_TLS_PASSPHRASE=x

echo "============================================================================================================"


# Check valid parameters
if [ ! -z ${MQ_TLS_KEYSTORE+x} ]; then
  if [ -z ${MQ_TLS_PASSPHRASE+x} ]; then
    echo "Error: If you supply MQ_TLS_KEYSTORE, you must supply MQ_TLS_PASSPHRASE"
    exit 1;
  fi
fi

# Set default unless it is set
MQ_DEV=${MQ_DEV:-"true"}
MQ_ADMIN_NAME="admin"
MQ_ADMIN_PASSWORD=${MQ_ADMIN_PASSWORD:-"passw0rd"}
MQ_APP_NAME="app"
MQ_APP_PASSWORD=${MQ_APP_PASSWORD:-""}

# Set needed variables to point to various MQ directories
DATA_PATH=`dspmqver -b -f 4096`
INSTALLATION=`dspmqver -b -f 512`

echo "Configuring app user"
if ! getent group mqclient; then
  # Group doesn't exist already
  groupadd --gid 1002 mqclient
fi
configure_os_user 1002 1002 MQ_APP_NAME MQ_APP_PASSWORD /home/app
# Set authorities to give access to qmgr, queues and topic
su -l mqm -c "setmqaut -m $1 -t qmgr -g mqclient +connect +inq"
su -l mqm -c "setmqaut -m $1 -n \"DEV.**\" -t queue -g mqclient +put +get +browse"
su -l mqm -c "setmqaut -m $1 -n \"DEV.**\" -t topic -g mqclient +sub +pub"

echo "Configuring admin user"
configure_os_user 1001 1000 MQ_ADMIN_NAME MQ_ADMIN_PASSWORD /home/admin

if [ "${MQ_DEV}" == "true" ]; then
  echo "Configuring default objects for queue manager: $1"
  set +e
  runmqsc $1 < /etc/mqm/mq-dev-config
  echo "ALTER CHANNEL('DEV.APP.SVRCONN') CHLTYPE(SVRCONN) MCAUSER('${MQ_APP_NAME}')" | runmqsc $1

  # If client password set to "" allow users to connect to application channel without a userid
  if [ "${MQ_APP_PASSWORD}" == "" ]; then
    echo "SET CHLAUTH('DEV.APP.SVRCONN') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) CHCKCLNT(ASQMGR) ACTION(REPLACE)" | runmqsc $1
  fi
  set -e
fi

if [ ! -z ${MQ_TLS_KEYSTORE+x} ]; then
# after a docker keystore restart, this is present, but its not enabling SSL on channels so remove instead
#  if [ ! -e "${DATA_PATH}/qmgrs/$1/ssl/key.kdb" ]; then
    echo "Configuring TLS for queue manager $1"
    mkdir -p /tmp/tlsTemp
    chown mqm:mqm /tmp/tlsTemp
    configure_tls $1
#  else
#    echo "A key store already exists at '${DATA_PATH}/qmgrs/$1/ssl/key.kdb'"
#  fi
else
  echo "SSL/TLS not enabled"
fi