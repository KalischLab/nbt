#!/opt/venv-nbt/bin/python

import os
import pydicom
import argparse
import pdb
import sys
import pandas as pd
import time
import pdb
from pydicom.errors import InvalidDicomError

def parse_args():
    parser = argparse.ArgumentParser(description="sortDicom reorganizes raw MRI data from the Prisma scanner into \
                                                 series-specific directories.")
    parser.add_argument("--transfer", help="Transfer data directly to project directory.",
                        action='store_true')
    parser.add_argument("--specify", help="Specify which data should be processed by one or multiple prefixes. For \
                        example if --specify Mey Sey Yue\" is chosen, only directories beginning with Mey, Sey or Yue \
                        will be processed. If --specify is not chosen, all directories will be processed.", \
                        nargs='+', default=[])
    return parser.parse_args()


def sanitize_string(in_str):
    in_str = in_str.replace(' ', '_')
    in_str = in_str.replace('>', '')
    in_str = in_str.replace('<', '')
    in_str = in_str.replace(':', '')
    in_str = in_str.replace('[', '')
    in_str = in_str.replace(']', '')
    in_str = in_str.replace('*', '')
    in_str = in_str.replace('(', '')
    in_str = in_str.replace(')', '')
    return in_str

def getfield_safe(hdr, field, default):
    try:
        return getattr(hdr, field)
    except AttributeError:
        return default

def is_directory_empty(directory):
    return not os.listdir(directory)

#Create errorlog filename
timestr = time.strftime("%Y%m%d-%H%M%S")
errorlog_file = "/mnt/nicshare/FromScanner/errorlog_" + timestr + ".txt"

def nic_sort_dicoms(args,dicomdir, fromscanner, toprojects, transferspec):


    if args.specify and not any(dicomdir.startswith(prefix) for prefix in args.specify):
        return
    else:
        print(f'Processing dicoms in {dicomdir}...')

    for filename in os.listdir(os.path.join(fromscanner, dicomdir)):

        file = os.path.join(fromscanner, dicomdir, filename)

        try:
            hdr = pydicom.dcmread(file)
        except InvalidDicomError:
            print(f'Error: {filename} is not a DICOM file!',file=open(errorlog_file,'a'))
            continue

        try:
            DA = getfield_safe(hdr, 'AcquisitionDate', 'NA')
            TA = getfield_safe(hdr, 'PerformedProcedureStepStartTime', 'NA')
            SN = getfield_safe(hdr, 'SeriesNumber', 'NA')
            SD = sanitize_string(getfield_safe(hdr, 'SeriesDescription', 'NA'))
            PN = sanitize_string(getfield_safe(hdr.PatientName, 'given_name', 'NA'))
            FN = sanitize_string(getfield_safe(hdr.PatientName, 'family_name', 'NA'))
            StD = sanitize_string(getfield_safe(hdr, 'StudyDescription', 'NA'))
            dest = os.path.join(toprojects, StD, f"{PN}_{FN}", f"{DA}_{TA}", f"{SD}_Series{SN:05d}")
        except Exception as e:
            print(f'Error: Destination path for {filename} cannot be created!',file=open(errorlog_file,'a'))
            continue

        if args.transfer is True:
            file_path= '/mnt/nicshare/FromScanner/code/transfer.xlsx'
            df = pd.read_excel(file_path, header=None)
            copy_dict = pd.Series(df[1].values, index=df[0]).to_dict()

            if StD in copy_dict:
                toprojects = copy_dict[StD]
                dest = os.path.join(toprojects,transferspec,f"{PN}_{FN}", f"{DA}_{TA}", f"{SD}_Series{SN:05d}")
            else:
                print('Warning: Automatic transfer was chosen but StudyDescriptor was not found in excel file! \
                      Sorted dicom files will be sent to /mnt/nicshare/FromScanner/data/projects .')

        if os.path.exists(os.path.join(dest, filename)):
            print(f'Warning: File {os.path.join(dest, filename)} already exists in target directory!')

            if os.path.getsize(os.path.join(dest,filename)) <= os.path.getsize(file):
                print(f'Existing file {os.path.join(dest, filename)} is smaller than file {file} from raw directory or of equal size and will be replaced.')
                syscom = "mv {} {}".format(file, dest)
                os.system(syscom)
            else:
                print(f'Existing file {os.path.join(dest, filename)} is larger than file {file} from raw directory. File from raw directory will be removed.')
                syscom = f"rm {file}"
                os.system(syscom)
        else: 
            if not os.path.exists(os.path.join(dest)):
                syscom = f"mkdir -p {dest}"
                os.system(syscom)

            syscom = "mv {} {}".format(file, dest)
            os.system(syscom)

    if is_directory_empty(os.path.join(fromscanner, dicomdir)):
        print(f"Dicom sorting for {os.path.join(fromscanner, dicomdir)} successful! ")
        #Add copy2project
        syscom = f"rm -rf {os.path.join(fromscanner, dicomdir)}"
        os.system(syscom)
    else:
        print(f"Error: Still files in {os.path.join(fromscanner, dicomdir)}!",file=open(errorlog_file,'a'))

def main():
    fromScanner = '/mnt/nicshare/FromScanner/data/raw'
    toProjects  = '/mnt/nicshare/FromScanner/data/projects'
    timestr = time.strftime("%Y%m%d-%H%M%S")
    transferspec = "FromScanner_" + timestr

    if is_directory_empty(fromScanner):
        print(f"No dicoms to be processed. {fromScanner} is empty.")
    else:
        args = parse_args()
        [nic_sort_dicoms(args,d, fromScanner, toProjects, transferspec) for d in os.listdir(fromScanner)
        if os.path.isdir(os.path.join(fromScanner, d))]

if __name__ == "__main__":
    main()

