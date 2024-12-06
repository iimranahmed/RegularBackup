#!/usr/bin/env python3

import logging
import json
import tarfile
import assist.generateBackup
#from assist import generateBackup
from os.path import exists


def main():
    logging.basicConfig(filename='localbackup.log', level=logging.INFO, format='%(asctime)s %(message)s')
    logging.info("Init local backup")
    cfg_file = 'config/files_to_backup.json';
    files_to_backup = assist.generateBackup.readJSON(cfg_file);
    tar_file = 'LocalBackup.tar.gz'
    success = assist.generateBackup.createCompressedLocalBackup(tar_file,files_to_backup)
    print("Success:", success)
    

if __name__ == '__main__':
    main()




