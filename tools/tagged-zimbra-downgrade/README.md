# Tagged Zimbra Downgrade

## Introduction

Have you tried to downgrade from a develop-branch build (i.e. ianw1974 builds) to a tagged build (i.e. Maldua builds) and found out that the installation abruptly ended with this message:

```
Creating server entry for mail.zimbrademo.net...already exists.
Setting Zimbra IP Mode...done.
Saving CA in ldap...failed.
```

?

Here there is an script to fix it.

## How to fix this

Make sure that Zimbra has started:
```
sudo su - zimbra -c 'zmcontrol start'
```

Download and apply the fix:
```
sudo su - zimbra
cd /tmp
wget 'https://github.com/maldua/zimbra-foss-builder/raw/main/tools/tagged-zimbra-downgrade/tagged-zimbra-downgrade.sh'
chmod +x tagged-zimbra-downgrade.sh
./tagged-zimbra-downgrade.sh
# Say 'y' to the question and press enter
exit
```

## Now just install/upgrade again

Use your tagged installation (i.e. Maldua installation):
```
./install.sh
```
to install/upgrade so that the installation is properly completed.
