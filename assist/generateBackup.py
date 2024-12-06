import logging
import json
import tarfile
from os.path import exists

def readJSON(inputFile):
    f = open(inputFile)
    jsonData = json.load(f)
    f.close()
    return jsonData

def fileExistGenerator(files_to_backup):
    for file in files_to_backup:
        logging.info('File "' + file + '" included in the tar')
        if( exists(file) ):
            yield file
        else:
            logging.error("Bad file Path: "+ file)
    

def createCompressedLocalBackup(tar_name,files_to_backup):
    if(len(list(fileExistGenerator(files_to_backup)))):
        tar = tarfile.open(tar_name, "w")
        for yield_file in fileExistGenerator(files_to_backup): 
            tar.add(yield_file)
        tar.close()
        return 1