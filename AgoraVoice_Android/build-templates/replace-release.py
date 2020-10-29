#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os

def main():
    keystore = ""
    password = ""
    alias = ""
    appId = ""
    customerId = ""
    customerCer = ""

    if "keystore" in os.environ:
        keystore = os.environ["keystore"]

    if "password" in os.environ:
        password = os.environ["password"]

    if "alias" in os.environ:
        alias = os.environ["alias"]

    if "appId" in os.environ:
            appId = os.environ["appId"]

    if "customerId" in os.environ:
        customerId = os.environ["customerId"]
        
    if "customerCert" in os.environ:
        customerCer = os.environ["customerCert"]

    f1 = open("./app/build.gradle", 'r+')
    content = f1.read()
    contentNew = re.sub(r'azure_keystore_file', keystore, content)
    contentNew = re.sub(r'azureKeystorePassword', password, contentNew)
    contentNew = re.sub(r'azure_keystore_alias', alias, contentNew)
    f1.seek(0)
    f1.write(contentNew)
    f1.truncate()
    f1.close()

    f2 = open("./app/src/main/res/values/strings.xml", 'r+')
    content = f2.read();
    contentNew = re.sub(r'<##APP_ID##>', appId, content)
    contentNew = re.sub(r'<##CUSTOMER_ID##>', customerId, contentNew)
    contentNew = re.sub(r'<##CUSTOMER_CER##>', customerCer, contentNew)
    f2.seek(0)
    f2.write(contentNew)
    f2.truncate()
    f2.close()

if __name__ == "__main__":
    main()