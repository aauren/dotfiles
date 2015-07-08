# Attempt to get the IP Address for a host by validating input, checking ssh config for aliases, resolving dig, and
# finally using getent
get_ip_for_host() {
	local ip= host=

	# Return it right away if it is already an IP address
	if is_ip_address "${1}"; then
		echo "${1}"
		return 0
	fi

	host="$(resolve_host_from_ssh_config ${1})"

	# Attempt to use dig to resolve the host
	ip=$(dig +short "${host}")
	if [[ ! -z ${ip} ]]; then
		echo "${ip}" | egrep -o '^([1-2]?[0-9]?[0-9]\.){3}([1-2]?[0-9]?[0-9])$'
		return 0
	fi

	# Attempt to use getent to resolve the host from host files
	if ip=$(getent hosts "${host}"); then
		echo "${ip}" | sed -r 's/(([1-2]?[0-9]?[0-9]\.){3}([1-2]?[0-9]?[0-9])).*$/\1/'
		return 0
	fi

	# We've failed, time to hang our head in shame and let our betters know
	return 1
}

# Validate the argument passed to determine if it is an IP Address or not
is_ip_address() {
	if [[ "${1}" =~ ^([1-2]?[0-9]?[0-9]\.){3}([1-2]?[0-9]?[0-9])$ ]]; then
		return 0
	else
		return 1
	fi
}

# Parse SSH config and turn key elements into a comma separated line instead of the otherwise unparsable standard
# config format
parse_ssh_config() {
	awk '
	BEGIN { IGNORECASE = 1; output = ""; run = 1 }
	$1 == "Host" {
		if ( run > 1 ) output = output"\n"
		run = run+1
		output = output$2;
		next;
	}
	$1 == "HostName" {
		output = output","$2;
		next;
	}
	$1 == "Port" {
		output = output","$2
	}
	END { print output }
	' ~/.ssh/config
}

# Check to see if the host is an alias in SSH config, even if it isn't, return the user's original input
resolve_host_from_ssh_config() {
	local host=
	# Attempt to see if this host is a shortcut in our ssh config, if it is, resolve it's hostname first
	host=$(parse_ssh_config | grep -e "^${1}," | cut -d',' -f2)
	echo "${host:-${1}}"
}
