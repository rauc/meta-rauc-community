/*
* Copyright (C) 2021 - Ahmed Kassem <ahmed.kassem56@gmail.com>
*/

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include "ota_update.h"

int main() {
    int result = 0;

    result = loadCurrentVersion(); 
    
    if (result < 0) {
        printf("Couldn't load current version!\n");
        return -1;
    }

    if (checkForUpdate() != 0) {
        printf("Update is required.\n");
        printf("Link:%s\n", tOTAInfo.downloadLink);
    } else {
        printf("Update is not required.\n");
        return 0;
    }

    result = downloadExtractUpdate();
    if (result < 0) {
        printf("Couldn't finish downloading/extracting the update\n");
        return -1;
    }

    result = installUpdate();

    if (result < 0) {
        printf("Couldn't finish installing the update\n");
        return -1;
    }

    printf("\n\n\n Updated successfully. Kindly reboot.\n\n\n");
}

int loadCurrentVersion() {
    FILE *fp = fopen("/etc/image_version", "r"); 
    if (fp != NULL) {
        fgets(currentVersion, 20, fp);
        fclose(fp);

        // Remove \n from the string
        char *newLinePtr = strchr(currentVersion,'\n'); 
        if (newLinePtr) {
            *newLinePtr = '\0';
        } 

    } else {
        printf("Couldn't load current image version\n");
        return -1;
    }
}

int checkForUpdate() {
    int res;
    FILE *fp; 
    char localBuff[1024];
    
    // Download file containing latest version information 
    res = executeCommand(1, "wget %s -O /tmp/ota_info", INFO_FILE_URL);

    if (res < 0) {
        printf("Couldn't download info file."); 
        return -1;
    }

    fp = fopen("/tmp/ota_info", "r");
    if (fp == NULL) {
        printf("An error occured while opening info file"); 
        return -1;
    }

    for (int line = 0; line < 3; line++) {
        char *ptrBuff = fgets(localBuff, 1024, fp); 
        if (ptrBuff != NULL) {

            // Remove \n from the buffer
            char *newLinePtr = strchr(localBuff,'\n'); 
            if (newLinePtr) {
                *newLinePtr = '\0';
            }

            switch (line) {
                case 0: 
                    // Version
                    strcpy(tOTAInfo.version, localBuff);
                    break;
                case 1:
                    // Download Link
                    strcpy(tOTAInfo.downloadLink, localBuff);
                    break;
                case 2:
                    // md5 checksum
                    strcpy(tOTAInfo.md5, localBuff);
                    break;
                default:
                    printf("Unexpected behaviour");
                    break;
            }
        } else {
            printf("An error occured while parsing ota info file.");
            fclose(fp);
            return -1;
        }
    }

    fclose(fp);

    printf("\nCurrent Version:%s - OTA Version:%s\n", currentVersion, tOTAInfo.version);

    return compVersions(tOTAInfo.version, currentVersion);
}

int downloadExtractUpdate() {
    int result = 0;
    // Remove old temp folder if existent
    result = executeCommand(1, "rm -rf /home/root/ota/tmp 2>&1"); 

    // Create new directories for downloads and extracting files
    result = executeCommand(1, "mkdir -p /home/root/ota/tmp/download /home/root/ota/tmp/download/extracted /home/root/ota/tmp/tmpMntPnt 2>&1");

    // Download ota file
    result = executeCommand(1, "wget '%s' -O /home/root/ota/tmp/download/ota.tar.bz2 2>&1", tOTAInfo.downloadLink);

    // File integrity check
    result = executeCommand(1, "md5sum /home/root/ota/tmp/download/ota.tar.bz2 2>&1");

    // Copy calculated MD5 from the stdout buffer to calculatedMD5 string
    strncpy(calculatedMD5, buff, 32);
    // String terminator for calculatedMD5
    calculatedMD5[32] = '\0';

    // Compare calculated MD5 with the one in the OTA file
    int fileIntegrityResult = strcmp(tOTAInfo.md5, calculatedMD5); 
    if (fileIntegrityResult != 0) {
        // Mismatch
        printf("MD5 mismatch. Try redownloading the file.\n");
        return -1;
    }

    // Extract downloaded file
    result = executeCommand(1, "tar xjf /home/root/ota/tmp/download/ota.tar.bz2 -C /home/root/ota/tmp/download/extracted 2>&1");

    return result;
}

int installUpdate() {
    int result = 0;
    const char** ptrMemDev;
    char currentBank;

    // Checking the current bank we're booted from and performing the installation on the other one.
    // Eg. if we're on bank a (mmcblk0p2) then we will install on bank b (mmcblk0p3) and vice versa
    result = executeCommand(1, "fw_printenv bank 2>&1");

    if (result > 0) {
        int cmpRes = strcmp((const char*) buff, bankAStr);

        if (cmpRes == 0) {
            printf("Installing OTA into Bank B\n");
            currentBank = 'a';
            ptrMemDev = &bankBDev;
        } else {
            cmpRes = strcmp((const char*) buff, bankBStr);
            if (cmpRes == 0) {
                printf("Installing OTA into Bank A\n");
                currentBank = 'b';
                ptrMemDev = &bankADev;
            } else {
                printf("Unexpeced bank string!\n");
            }
        }
        printf("Device: %s\n", *ptrMemDev);
    }

    // Formatting rootfs partition as ext4 partition with the label being root_bank
    result = executeCommand(1, "mkfs.ext4 %s -F -L root_%c 2>&1", *ptrMemDev, currentBank == 'a' ? 'b' : 'a');

    // Binary copy rootfs from the downloaded ota file
    result = executeCommand(1, "dd if=/home/root/ota/tmp/download/extracted/rootfs.ext4 of=%s conv=notrunc 2>&1", *ptrMemDev);
    
    // Resize the rootfs file system to fill the partition size
    result = executeCommand(1, "resize2fs %s 2>&1", *ptrMemDev);

    // Mounting the new rootfs to copy current fstab into
    result = executeCommand(1, "mount %s /home/root/ota/tmp/tmpMntPnt/ 2>&1", *ptrMemDev);

    // Copy fstab from the currently running rootfs to the updated one
    result = executeCommand(1, "cp /etc/fstab /home/root/ota/tmp/tmpMntPnt/etc/fstab 2>&1");

    // Unmount 
    result = executeCommand(1, "umount %s 2>&1", *ptrMemDev);

    // Upgrade kernel image
    result = executeCommand(1, "cp /home/root/ota/tmp/download/extracted/kernel /boot/kernel_%c 2>&1", currentBank == 'a' ? 'b' : 'a');

    // Telling u-boot to boot from the newly upgraded bank.
    result = executeCommand(1, "fw_setenv bank %c 2>&1", currentBank == 'a' ? 'b' : 'a');

    // Remove temp download and extracted files
    result = executeCommand(1, "rm -rf /home/root/ota 2>&1"); 

    // Reboot
    result = executeCommand(1, "reboot 2>&1");

    return result;
}

int executeCommand(int printOutput, char* format, ...) {
    va_list aptr;
    char ch;
    int responseLength = 0;
    FILE *fp;
    char cmd[256];
    static char gKillSwitch = 0;

    // Kill Switch! If a previous command failed we will no longer execute any command.
    if (gKillSwitch == 1) {
        return -1;
    }
    // Construct command using vargs
    va_start(aptr, format);
    vsprintf(cmd, format, aptr);
    va_end(aptr);

#ifdef DEBUG_SHOWCOMMANDS
    printf("Executing command: %s\n", cmd);
#endif

    if ((fp = popen(cmd, "r")) == NULL) {
        printf("Error opening pipe!\n");
        gKillSwitch = 1;
        return -1;
    }

    do {
        ch = fgetc(fp);
        if (feof(fp)) {
            break;
        }
        if (responseLength >= BUFSIZE) {
            responseLength = 0;
        }
        buff[responseLength++] = ch;
        if (printOutput == 1) {
            printf("%c", ch);
        }
    } while (1);

    if(pclose(fp))  {
        printf("Command not found or exited with error status\n");
        gKillSwitch = 1;
        return -1;
    }

    buff[responseLength-1] = '\0';

    return(responseLength);
}

int compVersions ( const char * version1, const char * version2 ) {
    unsigned major1 = 0, minor1 = 0, bugfix1 = 0;
    unsigned major2 = 0, minor2 = 0, bugfix2 = 0;
    sscanf(version1, "%u.%u.%u", &major1, &minor1, &bugfix1);
    sscanf(version2, "%u.%u.%u", &major2, &minor2, &bugfix2);
    if (major1 < major2) return -1;
    if (major1 > major2) return 1;
    if (minor1 < minor2) return -1;
    if (minor1 > minor2) return 1;
    if (bugfix1 < bugfix2) return -1;
    if (bugfix1 > bugfix2) return 1;
    return 0;
}