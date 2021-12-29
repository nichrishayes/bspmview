# This code was originally developed by Nicholas Christopher-Hayes #

# WARNING: This should be revised to register to MNI first, then binarize masks

proc_func(){
	printf "Processing: $1\n\n\n\n\n\n\n\n\n\n\n\n\n\n";

	# convert masks to nifti
	mri_convert $3/$1/mri/rh.hippoAmygLabels-T1-t2HcSlab.v21.mgz $3/$1/mri/rh.hippoAmygLabels-T1-t2HcSlab.v21.nii.gz
	mri_convert $3/$1/mri/lh.hippoAmygLabels-T1-t2HcSlab.v21.mgz $3/$1/mri/lh.hippoAmygLabels-T1-t2HcSlab.v21.nii.gz

	#threshold out hippo and amygd separately
	fsl5.0-fslmaths $3/$1/mri/rh.hippoAmygLabels-T1-t2HcSlab.v21.nii.gz -uthr 8000 -thr 7000 $3/$1/mri/rh.hippoAmygLabels-T1-t2HcSlab.v21_amygdalasubs.nii.gz
	fsl5.0-fslmaths $3/$1/mri/rh.hippoAmygLabels-T1-t2HcSlab.v21.nii.gz -uthr 300 -thr 200 $3/$1/mri/rh.hippoAmygLabels-T1-t2HcSlab.v21_hipposubs.nii.gz

	fsl5.0-fslmaths $3/$1/mri/lh.hippoAmygLabels-T1-t2HcSlab.v21.nii.gz -uthr 8000 -thr 7000 $3/$1/mri/lh.hippoAmygLabels-T1-t2HcSlab.v21_amygdalasubs.nii.gz
	fsl5.0-fslmaths $3/$1/mri/lh.hippoAmygLabels-T1-t2HcSlab.v21.nii.gz -uthr 300 -thr 200 $3/$1/mri/lh.hippoAmygLabels-T1-t2HcSlab.v21_hipposubs.nii.gz


	# make output path #
	mkdir -p $2/$1/

	# copy over T1 as well
	mri_convert $3/$1/mri/orig.mgz $3/$1/mri/orig.nii.gz
	mri_vol2vol --s $1 --mov $3/$1/mri/orig.nii.gz --targ $FREESURFER_HOME/average/mni305.cor.mgz \
	--xfm $3/$1/mri/transforms/talairach.xfm --o  $3/$1/mri/${1}_orig_mni.nii.gz
	


	# map them to mni space
	mri_vol2vol --s $1 --mov $3/$1/mri/rh.hippoAmygLabels-T1-t2HcSlab.v21_amygdalasubs.nii.gz --targ $FREESURFER_HOME/average/mni305.cor.mgz \
	--xfm $3/$1/mri/transforms/talairach.xfm --o $2/$1/${1}_rh_amygd.nii.gz

	mri_vol2vol --s $1 --mov $3/$1/mri/lh.hippoAmygLabels-T1-t2HcSlab.v21_amygdalasubs.nii.gz --targ $FREESURFER_HOME/average/mni305.cor.mgz \
	--xfm $3/$1/mri/transforms/talairach.xfm --o $2/$1/${1}_lh_amygd.nii.gz


	mri_vol2vol --s $1 --mov $3/$1/mri/rh.hippoAmygLabels-T1-t2HcSlab.v21_hipposubs.nii.gz --targ $FREESURFER_HOME/average/mni305.cor.mgz \
	--xfm $3/$1/mri/transforms/talairach.xfm --o $2/$1/${1}_rh_hippo.nii.gz

	mri_vol2vol --s $1 --mov $3/$1/mri/lh.hippoAmygLabels-T1-t2HcSlab.v21_hipposubs.nii.gz --targ $FREESURFER_HOME/average/mni305.cor.mgz \
	--xfm $3/$1/mri/transforms/talairach.xfm --o $2/$1/${1}_lh_hippo.nii.gz


	# create a binary version of all masks
	fsl5.0-fslmaths $2/$1/${1}_rh_amygd.nii.gz -bin -fillh $2/$1/${1}_rh_amygd_bin.nii.gz
	fsl5.0-fslmaths $2/$1/${1}_lh_amygd.nii.gz -bin -fillh $2/$1/${1}_lh_amygd_bin.nii.gz
	fsl5.0-fslmaths $2/$1/${1}_rh_hippo.nii.gz -bin -fillh $2/$1/${1}_rh_hippo_bin.nii.gz
	fsl5.0-fslmaths $2/$1/${1}_lh_hippo.nii.gz -bin -fillh $2/$1/${1}_lh_hippo_bin.nii.gz

	
	# set the orientation 
	fslswapdim $3/$1/mri/${1}_orig_mni.nii.gz RL PA IS $3/$1/mri/${1}_orig_mni_rpi.nii.gz

	fslswapdim $2/$1/${1}_rh_amygd_bin.nii.gz RL PA IS $2/$1/${1}_rh_amygd_bin_rpi.nii.gz
	fslswapdim $2/$1/${1}_lh_amygd_bin.nii.gz RL PA IS $2/$1/${1}_lh_amygd_bin_rpi.nii.gz
	fslswapdim $2/$1/${1}_rh_hippo_bin.nii.gz RL PA IS $2/$1/${1}_rh_hippo_bin_rpi.nii.gz
	fslswapdim $2/$1/${1}_lh_hippo_bin.nii.gz RL PA IS $2/$1/${1}_lh_hippo_bin_rpi.nii.gz



}
export -f proc_func
maskdir=/DATA/DevCoG/derivatives/t2HcSlab/fs_output_mni_space
SUBJECTS_DIR=/DATA/DevCoG/derivatives/freesurfer



cat ../docs/amygdala_subnuclei_project/2021_06_03_final_crossec_sample.csv | cut -d , -f 1 | sed 's:\/:_:g' | parallel --eta --jobs 4 proc_func "{}" "$maskdir" "$SUBJECTS_DIR"
