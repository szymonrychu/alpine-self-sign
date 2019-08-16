#!/bin/bash
# root dir
if [ -z "$CA_DIR" ]; then
    CA_DIR=/ca
    if [[ ! -d $CA_DIR ]]; then
        mkdir $CA_DIR
    fi
fi
# filenames
if [ -z "$ROOT_KEY_OUTPUT_FN" ]; then
    ROOT_KEY_OUTPUT_FN="rootCA.key"
fi
if [ -z "$ROOT_CRT_OUTPUT_FN" ]; then
    ROOT_CRT_OUTPUT_FN="rootCA.crt"
fi
if [ -z "$SELFSIGN_KEY_OUTPUT_FN" ]; then
    SELFSIGN_KEY_OUTPUT_FN="selfsign.key"
fi
if [ -z "$SELFSIGN_CRT_OUTPUT_FN" ]; then
    SELFSIGN_CRT_OUTPUT_FN="selfsign.csr"
fi
if [ -z "$SELFSIGN_CSR_OUTPUT_FN" ]; then
    SELFSIGN_CSR_OUTPUT_FN="selfsign.crt"
fi
if [ -z "$CA_BUNDLE_OUTPUT_FN" ]; then
    CA_BUNDLE_OUTPUT_FN="ca_bundle.crt"
fi

# Subject for root
if [ -z "$ROOT_C" ]; then
    ROOT_C="US"
fi
if [ -z "$ROOT_ST" ]; then
    ROOT_ST="CA"
fi
if [ -z "$ROOT_O" ]; then
    ROOT_O="Onegini"
fi
if [ -z "$ROOT_CN" ]; then
    ROOT_CN="rootCA"
fi

# Subject for selfsign
if [ -z "$SELFSIGN_C" ]; then
    SELFSIGN_C="US"
fi
if [ -z "$SELFSIGN_ST" ]; then
    SELFSIGN_ST="CA"
fi
if [ -z "$SELFSIGN_O" ]; then
    SELFSIGN_O="Onegini"
fi
if [ -z "$SELFSIGN_CN" ]; then
    SELFSIGN_CN="selfsign"
fi





if [[ ! -f "$CA_DIR/$ROOT_KEY_OUTPUT_FN" ]]; then
    echo "generate rootCA key"
    openssl genrsa -out $CA_DIR/$ROOT_KEY_OUTPUT_FN 4096
fi
if [[ ! -f "$CA_DIR/$ROOT_CRT_OUTPUT_FN" ]]; then
    echo "generate rootCA cert"
    openssl req -sha256 -x509 -new -nodes -key $CA_DIR/$ROOT_KEY_OUTPUT_FN -subj "/C=$ROOT_C/ST=$ROOT_ST/O=$ROOT_O/CN=$ROOT_CN" -days 3650 -out $CA_DIR/$ROOT_CRT_OUTPUT_FN
fi
if [[ ! -f "$CA_DIR/$SELFSIGN_KEY_OUTPUT_FN" ]]; then
    echo "generate selfisgned key"
    openssl genrsa -out $CA_DIR/$SELFSIGN_KEY_OUTPUT_FN 2048
fi
if [[ ! -f "$CA_DIR/$SELFSIGN_CSR_OUTPUT_FN" ]]; then
    echo "generate selfsigned signing request"
    openssl req -new -sha256 -key $CA_DIR/$SELFSIGN_KEY_OUTPUT_FN -subj "/C=$SELFSIGN_C/ST=$SELFSIGN_ST/O=$SELFSIGN_O/CN=$SELFSIGN_CN" -out $CA_DIR/$SELFSIGN_CRT_OUTPUT_FN
fi
if [[ ! -f "$CA_DIR/$SELFSIGN_CRT_OUTPUT_FN" ]]; then
    echo "generate selfsigned cert signed by root CA"
    openssl x509 -req -in $CA_DIR/$SELFSIGN_CSR_OUTPUT_FN -CA $CA_DIR/$ROOT_CRT_OUTPUT_FN -CAkey $CA_DIR/$ROOT_KEY_OUTPUT_FN -CAcreateserial -out $CA_DIR/$SELFSIGN_CRT_OUTPUT_FN -days 3650 -sha256
fi

cat $CA_DIR/$ROOT_CRT_OUTPUT_FN > $CA_DIR/$CA_BUNDLE_OUTPUT_FN
cat $CA_DIR/$ROOT_CRT_OUTPUT_FN >> $CA_DIR/$CA_BUNDLE_OUTPUT_FN