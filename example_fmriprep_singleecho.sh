
list="sub-S07 sub-S08" # sub-S10 sub-S39 sub-S40"

BidsBase="/mnt/nicshare/N2O_Fear/data/bids_task/"

for d in $list ; do
	docker run -ti --rm -u $(id -u ${USER}):$(id -g ${USER}) \
	-v $BidsBase:/base \
    nipreps/fmriprep:25.2.5 \
    /base/Nifti \
    /base/derivatives \
    participant \
	--participant-label $d \
    --fs-license-file /base/license.txt \
    --no-submm-recon \
    --fs-no-reconall \
    --dummy-scans 5
done

