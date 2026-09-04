
BidsBase="/mnt/nicshare/EEG_fmri_ext/data/bids/"
Derivatives="derivatives/"
DerivativesOri="${BidsBase}${Derivatives}"

for subject in "sub-S28 sub-S29 sub-S30 sub-S31 sub-S32 sub-S33 sub-S34"; do

    d=$(basename "$subject")

    outdir="${DerivativesOri}${d}"
    if [ -d $outdir ]; then
        echo "$subject has already been preprocessed..."
        continue
    else
        echo "Preprocessing $d..."
    fi

	docker run -ti --cpuset-cpus="0-15" --rm -u $(id -u ${USER}):$(id -g ${USER}) \
	-v $BidsBase:/base \
	nipreps/fmriprep:25.2.5 \
	/base/Nifti \
	/base/derivatives \
	participant \
	--participant-label $d \
	--fs-license-file /base/license.txt \
	--me-output-echos \
	--no-submm-recon \
	--fs-no-reconall

    	echo "...done"
done

