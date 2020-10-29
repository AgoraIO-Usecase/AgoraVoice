#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os

def main():
    appId = ""
    customerId = ""
    customerCer = ""

    if "appId" in os.environ:
            appId = os.environ["appId"]

    if "customerId" in os.environ:
        customerId = os.environ["customerId"]
        
    if "customerCert" in os.environ:
        customerCer = os.environ["customerCert"]

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