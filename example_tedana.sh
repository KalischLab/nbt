PROJECTDIR="/mnt/nicshare/NIC_other/Biomedizin/data/bids/"
PROJECTDIR_tmp="/home/mey1b/Biomedizin/data/bids/"
DERIVATIVES="${PROJECTDIR}"derivatives""
DERIVATIVES_tmp="${PROJECTDIR_tmp}"derivatives""

mkdir -p $DERIVATIVES_tmp

SUBDIR="$DERIVATIVES/sub-S11/"
SCANID="task-rest_acq-mb3me4"
SESSION="session1"

for d in $SUBDIR; do

    curindir=${d}
    curindir_tmp=${curindir/$PROJECTDIR/$PROJECTDIR_tmp}

    echo ${curindir_tmp}
    echo ${curindir}

    cp -r $curindir $curindir_tmp

    subject=$(basename "$d")

    echo $subject

    outdir="${d}/ses-${SESSION}/func/tedana"

    tedana_tmp="${curindir_tmp}ses-${SESSION}/func/tedana"
    tedana_dest="${curindir}ses-${SESSION}/func/tedana"

    if [ -d $outdir ]; then
        echo "$outdir already exists...Will be removed"
        rm -rf $outdir
    fi

    nbt_tedana.py $PROJECTDIR_tmp $SCANID -subs ${subject} -sess $SESSION
	
    cp -r $tedana_tmp $tedana_dest
    rm -rf $curindir_tmp

done

