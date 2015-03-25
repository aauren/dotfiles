#!/bin/bash

GIT_REPO_LOCATION="/home/auren/git-repos"
SSHFS_MOUNT_DIR="/mnt"
LIB_DIRS=("usr/lib32" "usr/lib64")
RSYNC_OPTS="-rpt --size-only --ignore-times --exclude=__pycache__"

#### Input Validation ####
if [[ $# -ne 2 ]]; then
	echo "Arguments: sync_program_files.sh git_project_name mounted_vm_name"
	exit 1
fi

project_name="$1"
project_directory="${project_name//-/_}"
project_path="${GIT_REPO_LOCATION}/${project_name}"
vm_path="${SSHFS_MOUNT_DIR}/$2"

if [[ ! -d ${project_path} ]]; then
	echo "Git project directory ${project_path} does not exist, cannot continue"
	exit 1
fi
if [[ ! -d ${vm_path} ]] || [[ ! -d ${vm_path}/usr ]]; then
	echo "Mounted vm root file system directory either does not exist or is not mounted at ${vm_path}"
	exit 1
fi

#### Function Declarations ####
get_project_python_versions ()
{
	ebuild_file="$1"
	echo "Checking ebuild for python versions: ${ebuild_file}"
	python_vers=$(grep "PYTHON_COMPAT" $1 | cut -d"(" -f2)
	python_vers=${python_vers::-1}
	IFS=' ' read -a python_ver_array <<< "${python_vers}"
}

find_remote_paths ()
{
	local python_ver=$1
	#echo "Checking version: ${python_ver}"
	for lib_dir in "${LIB_DIRS[@]}"; do
		local full_path="${vm_path}/${lib_dir}/${python_ver}/site-packages/${project_directory}"
		#echo "Checking Path: ${full_path}"
		if [[ -d ${full_path} ]]; then
			paths+=(${full_path})
		fi
	done
}

sync_files ()
{
	local src_path=$1
	local dst_path=$2
	local extra_opts=$3
	rsync_changes=$(rsync ${RSYNC_OPTS} ${extra_opts} "${src_path}" "${dst_path}")
}

#### Main Execution Thread ####
total_python_ver=()
for ebuild in ${project_path}/deploy/*.ebuild; do
	get_project_python_versions "${ebuild}"
	total_python_ver=("${total_python_ver[@]}" "${python_ver_array[@]}")
done
echo "Found python versions: ${total_python_ver[@]}"

for python_version in ${total_python_ver[@]}; do
	paths=()
	python_version=${python_version/_/.}
	find_remote_paths "${python_version}"
done
echo "Remote Paths: ${paths[@]}"

src_sync_path="${project_path}/src/${project_directory}/"
for my_path in ${paths[@]}; do
	sync_files "${src_sync_path}" "${my_path}" "-ni"
	if [[ ! -n ${rsync_changes} ]]; then
		echo -e "\tEverything is up to date! There are no changes to be made to this directory"
		continue
	fi

	echo -e "\nChanges that would be made to ${my_path}:"
	echo ${rsync_changes}
	resp=""
	while [[ ! $resp =~ ^(y|n)+$ ]]; do
		echo -e '\nAccept above changes? (y/n)'
		read resp
	done
	if [[ $resp = y ]]; then
		sync_files "${src_sync_path}" "${my_path}"
		echo "Changes successfully synced"
	else
		echo "Not syncing changes"
	fi
done
