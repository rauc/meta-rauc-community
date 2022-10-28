/*
* Copyright (C) 2021 - Ahmed Kassem <ahmed.kassem56@gmail.com>
*/

#ifndef OTA_UPDATE_H
#define OTA_UPDATE_H

#define BUFSIZE 256
#define DEBUG_SHOWCOMMANDS

#define INFO_FILE_URL "https://raw.githubusercontent.com/ahmedkassem56/qemuarma9_ota_latest_ver/master/info.txt"

char buff[BUFSIZE];

struct {
    char version[20];
    char downloadLink[1024];
    char md5[33];
} tOTAInfo ; 

char calculatedMD5[33];

char currentVersion[20];

const char* bankAStr = "bank=a";
const char* bankBStr = "bank=b";

const char* bankADev = "/dev/mmcblk0p2";
const char* bankBDev = "/dev/mmcblk0p3";

int executeCommand(int printOutput, char* format, ...);
int loadCurrentVersion(); 
int checkForUpdate();
int installUpdate();
int downloadExtractUpdate();
int compVersions ( const char * version1, const char * version2 );

#endif