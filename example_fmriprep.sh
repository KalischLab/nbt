#PROJECTDIR="/mnt/nicshare/GPC/data/GLC_Studie/bids/Nifti"
#for d in $PROJECTDIR/*/; do
#	subject=$(basename "$d")
#done

#########################################################
#1. Enter list of subjects to be processed
#list="sub-GLCID00014 sub-GLCID00017 sub-GLCID00018"\
#"sub-GLCID00019 sub-GLCID00020 sub-GLCID00021 "\
#"sub-GLCID00022 sub-GLCID00023 sub-GLCID00024 "\
#"sub-GLCID00025 sub-GLCID00026 sub-GLCID00027 "\
#"sub-GLCID00028 sub-GLCID00029 sub-GLCID00030 "\
#"sub-GLCID00031 sub-GLCID00032 sub-GLCID00033 "\
#"sub-GLCID00034 sub-GLCID00035 sub-GLCID00036"

list="sub-GLCID00448 sub-GLCID00450 "\
"sub-GLCID00451 sub-GLCID00452 "\
"sub-GLCID00455 sub-GLCID00456 "\
"sub-GLCID00457 sub-GLCID00461 "\
"sub-GLCID00463 sub-GLCID00464 "\
"sub-GLCID00470 sub-GLCID00471 "\
"sub-GLCID00472 sub-GLCID00475 "\
"sub-GLCID00476 sub-GLCID00481 "\
"sub-GLCID00482"
#########################################################
#2. Enter path to original bids base directory
BidsBase="/mnt/nicshare/GPC/data/bids/"
#########################################################
#3. Enter path to local temporary bids directory
TmpBidsBase="/home/mey1b/GPC_Studie_tmp/bids/"
TmpBase="/home/mey1b/GPC_Studie_tmp/"
#########################################################

Nifti="Nifti/"
Derivatives="derivatives/"
Dataset="Nifti/dataset_description.json"
License="license.txt"
DatasetOri="$BidsBase$Dataset"
DatasetTmp="$TmpBidsBase$Dataset"
LicenseOri="$BidsBase$License"
LicenseTmp="$TmpBidsBase$License"
NiftiOri="$BidsBase$Nifti"
NiftiTmp="$TmpBidsBase$Nifti"
DerivativesOri="$BidsBase$Derivatives"
DerivativesTmp="$TmpBidsBase$Derivatives"

#docker run -ti --rm -u $(id -u ${USER}):$(id -g ${USER}) \
#-v $BidsBase:/data:ro bids/validator:latest /data/Nifti

for d in $list ; do

	mkdir -p $NiftiTmp

	echo "Copy dataset and license file to temporary directory..."
	cp -rf $DatasetOri $DatasetTmp
	cp -rf $LicenseOri $LicenseTmp
	echo "...done!"

        echo "Copy data of next subject to temporary directory..."
	cp -rf $NiftiOri$d $NiftiTmp
        echo "...done"
##########################################################
#4. Enter docker command
	docker run -ti --rm -u $(id -u ${USER}):$(id -g ${USER}) \
	-v $TmpBidsBase:/base \
	nipreps/fmriprep:latest \
	/base/Nifti \
	/base/derivatives \
	participant \
	--participant-label $d \
	--fs-license-file /base/license.txt \
	--me-output-echos \
	--no-submm-recon \
	--fs-no-reconall \
	--skip-bids-validation \
	-t rest1
	
	echo "Copy preprocessed data to original directory and remove temporary files..."
	DerivSubOri="$DerivativesOri"
	DerivSubTmp="$DerivativesTmp$d"
	html=".html"
	DerivSubOriHtml="$DerivativesOri/$d$html"
	DerivSubTmpHtml="$DerivativesTmp/$d$html"

	cp -rf $DerivSubTmp $DerivSubOri 
	cp -rf $DerivSubTmpHtml $DerivSubOriHtml 
	rm -rf $TmpBase
    	echo "...done"
done

