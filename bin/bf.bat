@echo off
cd C:\cootest\lib\javalib\
java -classpath . -cp "blowfish-1.0.jar;." BlowfishWrapper %1 %2 %3
