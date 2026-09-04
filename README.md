# nbt

nbt (nic bids tools) is a customized collection of python scripts facilitating BIDS-conversion, fMRIprep usage and analyses of BIDS datasets.

# How to convert raw NIC MRI data into a BIDS dataset and preprocess functional MRI data

1. nbt tools and fmriprep can only be used on Linux systems. All nbt scripts are preinstalled on the Linux VM and the Linux server. If you do not have an account on the Linux VM (or the Linux server) please ask the Linux admins to get an account and a project directory on the nicshare drive. Raw DICOM files must be copied to your nicshare project directory and must be organized in subject and session subdirectories [e.g. raw/sub1/session1, raw/sub1/session2, raw/sub2/...]
2. A json-formatted template file defining the data structure of the raw MRI data must be created. The template must contain a subject object with keys "subjectID" (subject ID) and "sessions" (array of objects each defining the session directory ("sessionDir"), session ID ("sessionID") and a "scans" array). Each "scans" object defines a particular MRI sequence by BIDS key-value pairs:

|key|value|
|---|-----|
|acq|BIDS acquisition (NIC descriptors like mb3me4 for multiband-factor 3 and 4 echos can be used here)|
|data_type|BIDS data type|
|dir|IDS phase encoding direction|
|echos|number of echos|
|intendedfor|list of fmri scans (task desriptors, e.g. ["rest1","fearcond"]) to which the fieldmap is applied |
|mod|BIDS modality|
|run|BIDS run|
|task|BIDS task name|

Example templates for multiecho and singleecho fMRI can be found in this repository.

3. Run nbt_assign.py to generate the dataset structure for the entire set of raw DICOM files.

**Usage: nbt_assign.py [OPTIONAL ARGUMENTS] template_json  raw_dicom data_json**

nbt_assign.py assigns BIDS key-value pairs to each DICOM image in **raw_dicom** according to a json-formatted template file (**template_json**). nbt_assign.py returns a json file (**data_json**) containing BIDS key-value pairs for all DICOM images with matches in **template_json**. **raw_dicom** must be organized in subject and session subdirectories [e.g. raw/sub1/session1, raw/sub1/session2, raw/sub2/...]. nbt_assign.py requires Python 3.XX plus some further packages (see imports in nbt_define.py). For more information type ./nbt_assign.py -h.

4. Run nbt_convert_2.py to convert dicom to niftis and to create a BIDS-compliant dataset  

**Usage: nbt_convert_2.py [OPTIONAL ARGUMENTS] [-lic LICENSE] data_json BIDS_outdir**

nbt_convert_2 performs BIDS-compliant dicom-to-nifti conversion. Nifti files are named according to the output file of nbt_assign.py (**data_json**). A Freesurfer-license file should be passed using the -lic option as it is required by fMRIprep. nbt_convert_2.py requires Python 3.XX and some additional packages (see imports in nbt_convert.py). For more information type ./nbt_convert_2.py -h.

5. Run fMRIprep

Please use e.g. a shell script that calls fmriprep for each single subject. Large multi-subject datasets may cause problems in the VM.

6. Run ntb_tedana.py (only required for multi echo data)

**Usage: nbt_tedana.py [OPTIONAL ARGUMENTS] BIDSbase fMRIprepID**

nbt_tedana.py performs tedana multi-echo ICA and optimal combination on partially preprocessed fMRIprep output data in **BIDSbase** (path to BIDS root directory containing an fMRIPrep derivatives folder). ANTs normalization and FSL masking is then performed to transform individual fMRI data to MNI-space. fMRIprep must have been performed using the --me-output-echos option. The **fMRIprepID** is a unique(!) BIDS-compliant file identifier including task (required), acq (optional) and run (optional) label, e.g., task-rest_acq-mb3me4_run-1. Labels must be part of the ME-filename. nbt_tedana.py requires Python 3.XX and some additional packages (see imports in nbt_tedana.py). For more information type ./nbt_tedana.py -h.

## Additional python scripts

**nbt_prettyjson.py**

**Usage: nbt_prettyjson.py ugly_json pretty_json**

nbt_prettyjson.py pretty prints json files (input file: **ugly_json**, output file: **pretty_json**)

**nbt_funcon.py**

Work in progress
