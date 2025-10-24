DOD DERILITY CA-1,

DOD DERILITY CA-3 through DOD DERILITY CA-6,

DOD EMAIL CA-62 through DOD EMAIL CA-65,

DOD EMAIL CA-70 through DOD EMAIL CA-73,

DOD EMAIL CA-78 through DOD EMAIL CA-81

DOD ID CA-62 through DOD ID CA-65,

DOD ID CA-70 through DOD ID CA-73,

DOD ID CA-78 through DOD ID CA-81

DoD Root CA 3 through DoD Root CA 6,

DOD SW CA-66 through DOD SW CA-69,

DOD SW CA-74 through DOD SW CA-77, and

DOD SW CA-82 through DOD SW CA-85

```bash
mkdir -p ${XDG_DATA_HOME:-$HOME}/certs
op item list --vault USAF --tags cac --format json | jq -r '.[] | "op document get \"\(.id)\" --out-file \"${XDG_DATA_HOME:-$HOME}/certs/\(.title).cer\""'

# Add Root Certificates
for cert in ${XDG_DATA_HOME:-$HOME}/certs/*ROOT*.cer; do
    sudo security add-trusted-cert \
        -p ssl -p smime -p codeSign -p IPSec -p basic -p swUpdate -p pkgSign -p timestamping -p eap \
        -d \
        -r trustRoot \
        -k /Library/Keychains/System.keychain "$cert"
done
rm ${XDG_DATA_HOME:-$HOME}/certs/*ROOT*.cer

# Add Intermediate Certificates
for cert in ${XDG_DATA_HOME:-$HOME}/certs/*.cer; do
    security add-trusted-cert \
        -p ssl -p smime -p codeSign -p IPSec -p basic -p swUpdate -p pkgSign -p timestamping -p eap -p pkgSign \
        -d \
        -r trustAsRoot \
        -k ~/Library/Keychains/login.keychain-db "$cert"
done
rm ${XDG_DATA_HOME:-$HOME}/certs/*.cer

# Importing PKCS#12 Files
for cert in ${XDG_DATA_HOME:-$HOME}/certs/*.p12; do
    security import "$cert" -k ~/Library/Keychains/login.keychain
done
rm ${XDG_DATA_HOME:-$HOME}/certs/*.p12
```
