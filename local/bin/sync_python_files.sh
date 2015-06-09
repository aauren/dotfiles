#!/bin/bash

#### Define Constants ####
GIT_REPO_LOCATION="/home/auren/git-repos"
LIB_DIRS=("/usr/lib32" "/usr/lib64")
RSYNC_OPTS="-rpt --checksum --ignore-times --exclude=__pycache__"
# Some explanation of the following options:
## LogLevel=Error: needed to supress any SSH banners that have been configured which screw up non-interactive sessions
## BatchMode=yes: needed to disable passphrase/password querying which would make this script need to be interactive
SSH_OPTS="-o LogLevel=Error -o BatchMode=yes -o ConnectTimeout=5 -l root"

#### Input Validation ####
if [[ $# -ne 2 ]]; then
	echo "Arguments: sync_program_files.sh git_project_name remote_server"
	exit 1
fi

project_name="$1"
project_directory="${project_name//-/_}"
project_path="${GIT_REPO_LOCATION}/${project_name}"
remote_server="$2"

if [[ ! -d ${project_path} ]]; then
	echo "Git project directory ${project_path} does not exist, cannot continue"
	exit 1
fi
ssh_status=$(\ssh ${SSH_OPTS} ${remote_server} echo ok 2>&1)
if [[ $ssh_status != ok ]]; then
	echo "It doesn't look like you have SSH access to: '${remote_server}'"
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
	python_ver_array2=()
	for item in "${python_ver_array[@]}"; do
		if [[ "${item}" == *\{*,*\}* ]]; then
			python_ver_array2+=($(eval echo ${item}))
		else
			python_ver_array2+=("${item}")
		fi
	done
	if [[ ! -z ${python_ver_array2} ]]; then
		python_ver_array="${python_ver_array2[@]}"
	fi
}

find_remote_paths ()
{
	local python_ver=$1
	#echo "Checking version: ${python_ver}"
	for lib_dir in "${LIB_DIRS[@]}"; do
		local full_path="${lib_dir}/${python_ver}/site-packages/${project_directory}"
		#echo "Checking Path: ${full_path}"
		if \ssh ${SSH_OPTS} ${remote_server} "[[ -d ${full_path} ]]"; then
			paths+=(${full_path})
		fi
	done
}

sync_files ()
{
	local src_path=$1
	local dst_path=$2
	local extra_opts=$3
	rsync_changes=$(rsync ${RSYNC_OPTS} ${extra_opts} "${src_path}" "root@${remote_server}:${dst_path}" 2>/dev/null)
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
	echo "${rsync_changes}"
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
