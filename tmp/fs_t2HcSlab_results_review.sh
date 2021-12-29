# This code was originally developed by Nicholas Christopher-Hayes #

proc_func(){
	printf "Processing: $1\n\n\n\n\n\n\n\n\n\n\n\n\n\n";

	fsleyes $3/$1/mri/orig_mni_space_rpi.nii.gz $2/$1/${1}_lh_hippocampus_rpi.nii.gz $2/$1/${1}_rh_hippocampus_rpi.nii.gz
}

export -f proc_func
maskdir=/home/ado_nebmeg/Data/DMAP/derivatives/t2HcSlab/fs_output_mni_space/bilater_t2HcSlab
anatdir=/home/ado_nebmeg/Data/DMAP/derivatives/
SUBJECTS_DIR=/home/ado_nebmeg/Data/DMAP/derivatives/freesurfer

ls -1 $SUBJECTS_DIR | grep sub | sed -n '8,10p' | parallel --eta --jobs 1 proc_func "{}" "$maskdir" "$SUBJECTS_DIR" "$anatdir"
