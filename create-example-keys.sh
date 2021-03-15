#!/bin/bash

set -e

if [ -z $BBPATH ]; then
  printf "Please call from within a set-up bitbake environment!\nRun 'source oe-init-build-env <builddir>' first\n"
  exit 1
fi

ORG="Test Org"
CA="rauc CA"

# After the CRL expires, signatures cannot be verified anymore
CRL="-crldays 5000"

BASE="$BBPATH/example-ca"

if [ -e $BASE ]; then
  echo "$BASE already exists"
  exit 1
fi

mkdir -p $BASE/{private,certs}
touch $BASE/index.txt
echo 01 > $BASE/serial

cat > $BASE/openssl.cnf <<EOF
[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]

dir            = .                     # top dir
database       = \$dir/index.txt        # index file.
new_certs_dir  = \$dir/certs            # new certs dir

certificate    = \$dir/ca.cert.pem       # The CA cert
serial         = \$dir/serial           # serial no file
private_key    = \$dir/private/ca.key.pem# CA private key
RANDFILE       = \$dir/private/.rand    # random number file

default_startdate = 19700101000000Z
default_enddate = 99991231235959Z
default_crl_days= 30                   # how long before next CRL
default_md     = sha256                # md to use

policy         = policy_any            # default policy
email_in_dn    = no                    # Don't add the email into cert DN

name_opt       = ca_default            # Subject name display option
cert_opt       = ca_default            # Certificate display option
copy_extensions = none                 # Don't copy extensions from request

[ policy_any ]
organizationName       = match
commonName             = supplied

[ req ]
default_bits           = 2048
distinguished_name     = req_distinguished_name
x509_extensions        = v3_leaf
encrypt_key = no
default_md = sha256

[ req_distinguished_name ]
commonName                     = Common Name (eg, YOUR name)
commonName_max                 = 64

[ v3_ca ]

subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
basicConstraints = CA:TRUE

[ v3_inter ]

subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
basicConstraints = CA:TRUE,pathlen:0

[ v3_leaf ]

subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
basicConstraints = CA:FALSE
EOF

export OPENSSL_CONF=$BASE/openssl.cnf

cd $BASE

echo "Development CA"
openssl req -newkey rsa -keyout private/ca.key.pem -out ca.csr.pem -subj "/O=$ORG/CN=$ORG $CA Development"
openssl ca -batch -selfsign -extensions v3_ca -in ca.csr.pem -out ca.cert.pem -keyfile private/ca.key.pem

echo "Development Signing Keys 1"
openssl req -newkey rsa -keyout private/development-1.key.pem -out development-1.csr.pem -subj "/O=$ORG/CN=$ORG Development-1"
openssl ca -batch -extensions v3_leaf -in development-1.csr.pem -out development-1.cert.pem


CONFFILE=${BUILDDIR}/conf/site.conf

echo ""
echo "Writing RAUC key configuration to site.conf ..."

if test -f $CONFFILE; then
if grep -q "^RAUC_KEYRING_FILE.*=" $CONFFILE; then
	echo "RAUC_KEYRING_FILE already configured, aborting key configuration"
	exit 0
fi
if grep -q "^RAUC_KEY_FILE.*=" $CONFFILE; then
	echo "RAUC_KEY_FILE already configured, aborting key configuration"
	exit 0
fi
if grep -q "^RAUC_CERT_FILE.*=" $CONFFILE; then
	echo "RAUC_CERT_FILE already configured, aborting key configuration"
	exit 0
fi
fi

echo "RAUC_KEYRING_FILE=\"${BUILDDIR}/example-ca/ca.cert.pem\"" >> $CONFFILE
echo "RAUC_KEY_FILE=\"${BUILDDIR}/example-ca/private/development-1.key.pem\"" >> $CONFFILE
echo "RAUC_CERT_FILE=\"${BUILDDIR}/example-ca/development-1.cert.pem\"" >> $CONFFILE

echo "Key configuration successfully written to ${BUILDDIR}/conf/site.conf"
