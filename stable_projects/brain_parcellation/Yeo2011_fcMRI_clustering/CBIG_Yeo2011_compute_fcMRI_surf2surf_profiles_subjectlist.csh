#!/bin/csh -f


# Assume the order of subjects list and surface data list are the same, since the surface data list is created from subjects list by CBIG_Yeo2011_create_subject_surf_list.csh
# Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

set VERSION = '$Id: CBIG_Yeo2011_compute_fcMRI_surf2surf_profiles_subjectlist.csh, v 1.0 2016/06/18 $'

set sub_dir = "";
set subjects = "";
set surf_list = "";
set target = fsaverage5
set roi = fsaverage3
set scrub_flag = 0;

set PrintHelp = 0;
set n = `echo $argv | grep -e -help | wc -l`
if( $#argv == 0 || $n != 0 ) then
	echo $VERSION
	# print help	
	cat $0 | awk 'BEGIN{prt=0}{if(prt) print $0; if($1 == "BEGINHELP") prt = 1 }'
	exit 0;
endif
set n = `echo $argv | grep -e -version | wc -l`
if( $n != 0 ) then
	echo $VERSION
	exit 0;
endif

goto parse_args;
parse_args_return:

goto check_params;
check_params_return:

set root_dir = `python -c "import os; print(os.path.realpath('$0'))"`
set root_dir = `dirname $root_dir`

set sub_list = `cat $subjects`
if( $scrub_flag == 1 ) then
	set outlier_files = ("`cat $outlier_list`")
endif

set i = 1;
foreach surf ("`cat ${surf_list}`")
	set s = $sub_list[$i];
	set output_dir = "${sub_dir}/${s}/surf2surf_profiles"
	if( ! -d $output_dir ) then
		mkdir $output_dir
	endif
	set cmd = "${root_dir}/CBIG_Yeo2011_compute_fcMRI_surf2surf_profiles.csh -sd ${sub_dir} -s ${s} -surf_data '${surf}' -target ${target} -roi ${roi} -output_dir ${output_dir}"
	if( $scrub_flag == 1 ) then
		set outlier = "$outlier_files[$i]"
		set cmd = "$cmd -outlier_files '$outlier'"
	endif
	echo $cmd
	eval $cmd
	@ i = $i + 1;
	#exit 0
end

exit 0

#############################
# parse arguments
#############################
parse_args:
set cmdline = "$argv";
while( $#argv != 0 )
	set flag = $argv[1]; shift;
	
	switch($flag)
		# subjects directory
		case "-sd":
			if( $#argv == 0 ) goto arg1err;
			set sub_dir = $argv[1]; shift;
			breaksw

		# subject list
		case "-sub_ls":
			if( $#argv == 0 ) goto arg1err;
			set subjects = $argv[1]; shift;
			breaksw

		# surface data list
		case "-surf_ls":
			if( $#argv == 0 ) goto arg1err;
			set surf_list = $argv[1]; shift;
			breaksw
			
		# outlier files list
		case "-outlier_ls":
			if( $#argv == 0 ) goto arg1err;
			set outlier_list = $argv[1]; shift;
			set scrub_flag = 1
			breaksw
			
		# target resolution
		case "-target":
			if( $#argv == 0 ) goto arg1err;
			set target = $argv[1]; shift;
			breaksw
			
		# ROI resolution
		case "-roi":
			if( $#argv == 0 ) goto arg1err;
			set roi = $argv[1]; shift;
			breaksw

		default:
			echo "ERROR: Flag $flag unrecognized."
			echo $cmdline
			exit 1;
			breaksw
	endsw
end

goto parse_args_return;


############################
# check parameters
############################
check_params:

if( $#sub_dir == 0 ) then
	echo "ERROR: subjects directory not specified."
	exit 1;
endif

if( $#subjects == 0 ) then
	echo "ERROR: subject list not specified."
	exit 1;
endif

if( $#surf_list == 0 ) then
	echo "ERROR: surface data list not specified."
	exit 1;
endif

goto check_params_return;


###########################
# Error message
###########################
arg1err:
  echo "ERROR: flag $flag requires one argument"
  exit 1;




exit 0

#-------- Everything below is printed as part of help --------#
BEGINHELP

NAME:
	CBIG_Yeo2011_compute_fcMRI_surf2surf_profiles_subjectlist.csh

DESCRIPTION:
	Given a subjects list, this function calls 'CBIG_Yeo2011_compute_fcMRI_surf2surf_profiles.csh' 
	for each subject to compute functional connectivity profiles on surface. The resolution
	of the functional connectivity is given by the inputs -target and -roi. Default is 
	fsaverage5 x fsaverage3.
	
	This function needs a surface data list (either lh or rh), which is created by 
	'CBIG_Yeo2011_create_subject_surf_list.csh' based on the subjects list. Therefore, the ordering 
	of subjects in subjects list and surface fMRI data list must be the same.
	If the lh surface data list is passed in, CBIG_Yeo2011_compute_fcMRI_surf2surf_profiles.csh will
	replace "lh" with "rh" when computing correlation for the right hemisphere.
	
	The motion outliers files list is optional. It is also generated by 'CBIG_Yeo2011_create_subject_surf_list.csh'. 
	If motion outliers files list is passed in, the high motion frames will be ignored when computing 
	functional connectivity. High motion frames are indicated by "0" in motion outliers files, while 
	low-motion frames are "1".

REQUIRED ARGUMENTS:
	-sd          sub_dir      : fMRI subjects directory. This directory contains all the folders
	                            named by the subject IDs.
	-sub_ls      sub_list     : subjects list (full path). Each line in this file is one subject ID.
	-surf_ls     surf_list    : surface fMRI data list (full path), created by 'CBIG_Yeo2011_create_subject_surf_list.csh'
	                            The user only needs to pass in one of the lh and rh surface fMRI lists.
	                            In the list, each line is all the surface fMRI filenames (lh or rh) 
	                            of all runs of one subject.
	
OPTIONAL ARGUMENTS:
	-outlier_ls  outlier_list : motion outliers files list (full path). It is created by 
	                            'CBIG_Yeo2011_create_subject_surf_list.csh' as well.
	-target      target       : the resolution of clustering (default is fsaverage5). 
	-roi         roi          : the resolution of ROIs (default is fsaverage3)
	
OUTPUTS:
	A "surf2surf_profiles" folder in the preprocessed fMRI folder of each subject.
	In this folder, 
	   
	1. "lh.<subject_id>.roifsaverage3.thres0.1.surf2surf_profile.input" 
	   is a text file where each line is the surface fMRI data (lh) of one run of <subject_id>.
	   
	2. "rh.<subject_id>.roifsaverage3.thres0.1.surf2surf_profile.input" 
	   is a text file where each line is the surface fMRI data (rh) of one run of <subject_id>.
	   
	3. "outlier.<subject_id>.roifsaverage3.thres0.1.surf2surf_profile.input"
	   is a text file where each line is the motion outlier filename of one run of <subject_id>
	   
	4. "lh.<subject_id>.roifsaverage3.thres0.1.surf2surf_profile_scrub.nii.gz"
	   is the surface to surface correlation file (lh) of <subject_id>. This correlation profile
	   is computed by choosing a seed in the mesh of <target> from left hemisphere and correlated
	   with all ROIs in the mesh of <roi> from both left and right hemisphere.
	   
	5. "rh.<subject_id>.roifsaverage3.thres0.1.surf2surf_profile_scrub.nii.gz"
	   is the surface to surface correlation file (rh) of <subject_id>. This correlation profile
	   is computed by choosing a seed in the mesh of <target> from right hemisphere and correlated
	   with all ROIs in the mesh of <roi> from both left and right hemisphere.

EXAMPLE:
	csh CBIG_compute_fcMRI_surf2surf_profiles_subjectlist.csh -sd ~/storage/fMRI_data -sub_ls 
	~/storage/fMRI_data/scripts/sub_list.txt -surf_list 
	~/storage/fMRI_clustering/lists/lh.surf_rest_skip4_stc_mc_resid_cen_FDRMS0.2_DVARS50_bp_0.009_0.08_fs6_sm6_fs5.list
	-outlier_ls ~/storage/fMRI_clustering/lists/outlier_FDRMS0.2_DVARS50_motion_outliers.list 
	-target fsaverage5 roi fsaverage3
  