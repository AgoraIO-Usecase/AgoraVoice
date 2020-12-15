#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os

def main():

    buglyId = ""
    if "Bugly_Id" in os.environ:
        buglyId = os.environ["Bugly_Id"]

    # KeyCenter.swift
    f = open("../../Center/Center/Keys.swift", 'r+')
    content = f.read()
    appString = "static var BuglyId: String = " + "\"" + buglyId + "\""
    contentNew = re.sub(r'static var BuglyId: String = \"\"', appString, content)
    f.seek(0)
    f.write(contentNew)
    f.truncate()
    
if __name__ == "__main__":
    main()
