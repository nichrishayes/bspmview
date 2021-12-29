# This code was originally developed by Nicholas Christopher-Hayes #

#https://surfer.nmr.mgh.harvard.edu/fswiki/HippocampalSubfieldsAndNucleiOfAmygdala

#<analysisID>.FSspace.mgz: the additional scan, rigidly registered to the T1 data.

# FS 6#
#[lr]h.hippoSfLabels-<T1>-<analysisID>.v10.mgz: they store the discrete segmentation volume at 0.333 mm resolution in the physical space of the FreeSurfer T1 data (and therefore of the aligned scan <analysisID>.FSspace.mgz as well).

# FS 7 #
# [lr]h.hippoAmygLabels-<T1>-<analysisID>.v21.[hierarchy].<FSvoxelSpace>.mgz

# FS 6 #
#[lr]h.hippoSfLabels-<T1>-<analysisID>.v10.FSvoxelSpace.mgz: they store the discrete segmentation volume in the FreeSurfer voxel space (i.e., that of nu.mgz, aseg.mgz, etc).
#[lr]h.hippoSfVolumes-<T1>-<analysisID>.v10.txt: these text files store the estimated volumes of the subfields and of the whole hippocampi. 

# FS 7 #
#[lr]h.hippoAmygLabels-T1.long.v21.[hierarchy].<FSvoxelSpace>.mgz: segmentations.
#[lr]h.hippoSfVolumes-T1.long.v21.txt: volumes of the hippocampal substructures.
#[lr]h.amygNucVolumes-T1.long.v21.txt: volumes of the nuclei of the amygdala



# FS 6 #
#freeview -v nu.mgz -v t2HcSlab.FSspace.mgz:sample=cubic \
#-v lh.hippoSfLabels-t2HcSlab.v10.mgz:colormap=lut -v rh.hippoSfLabels-t2HcSlab.v10.mgz:colormap=lut

# FS 7 #
#freeview -v nu.mgz -v t2HcSlab.FSspace.mgz:sample=cubic \
#-v lh.hippoAmygLabels-T1-t2HcSlab.v21.mgz:colormap=lut -v rh.hippoAmygLabels-T1-t2HcSlab.v21.mgz:colormap=lut

# FS 6 #
#quantifyHippocampalSubfields.sh <T1>-<analysisID> <output_file> <OPTIONAL_subject_directory>
#quantifyHippocampalSubfields.sh t2HcSlab t2HcSlab.csv /home/ado_nebmeg/Data/DMAP/derivatives/freesurfer

# FS 7 #
#quantifyHAsubregions.sh hippoSf <T1>-<analysisID> <output_file> <OPTIONAL_SUBJECTS_DIR>
#quantifyHAsubregions.sh amygNuc <T1>-<analysisID> <output_file> <OPTIONAL_SUBJECTS_DIR>

# FS 6 #
#Transform: $SUBJECTS_DIR/<subject_name>/mri/transforms/T1_to_<analysisID>.v10.lta

# FS 7 #
#Transform: $SUBJECTS_DIR/<subject_name>/mri/transforms/T1_to_<analysisID>.v21.lta 


#Quality Controls: mri/transforms/T1_to_<analysisID>.v10.QC.gif
proc_func(){
	printf "Processing: $1\n\n\n\n\n\n";


	subID=`echo $1 | cut -d / -f 1`;
	fsSubID=`echo $1 | sed 's:\/:_:g'`;
	seshID=`echo $1 | cut -d / -f 6`;


	cp $2/$1/${subID}.nii.gz $3/$fsSubID/mri/orig_hc_t2.nii.gz

	# Freesurfer 6
	#recon-all -s $fsSubID -hippocampal-subfields-T2 $fsOutputDir/$fsSubID/mri/orig_hc_t2.nii.gz "t2HcSlab" -no-isrunning
	#-itkthreads 4: optional argument to allow more cores to be used

	# Freesurfer 7
	segmentHA_T2.sh $fsSubID $3/$fsSubID/mri/orig_hc_t2.nii.gz "t2HcSlab" 1 $3
	# Freesurfer 7 Longitudinal #
	#segmentHA_T1_long.sh <baseID>  [SUBJECTS_DIR]

}
export -f proc_func
#to also write out soft segmentations (i.e. posterior probabilities)
export WRITE_POSTERIORS=1
#setenv WRITE_POSTERIORS 1

t2HcSlabInputDir=/DATA/DevCoG/raw/t2HcSlab/nifti
SUBJECTS_DIR=/DATA/DevCoG/derivatives/freesurfer

cat ../docs/2021_06_04_freesurfer_proc.txt | parallel --eta --jobs 6 proc_func "{}" "$t2HcSlabInputDir" "$SUBJECTS_DIR"
#find ../raw/anat/dicom/ -iname "*ses-*" -type d | parallel --eta --jobs 6 proc_func "{}"
#find ../raw/t2HcSlab/dicom/ -iname "*ses-*" -type d | parallel --eta --jobs 6 proc_func "{}"


