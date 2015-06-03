get_ip_for_host() {
	local ip=

	if is_ip_address "${1}"; then
		echo "${1}"
		return 0
	else
		ip=$(dig +short "${1}")
		if [[ ! -z ${ip} ]]; then
			echo "${ip}" | egrep -o '^([1-2]?[0-9]?[0-9]\.){3}([1-2]?[0-9]?[0-9])$'
			return 0
		fi
		if ip=$(getent hosts "${1}"); then
			echo "${ip}" | sed -r 's/(([1-2]?[0-9]?[0-9]\.){3}([1-2]?[0-9]?[0-9])).*$/\1/'
			return 0
		fi
	fi
	return 1
}

is_ip_address() {
	if [[ "${1}" =~ ^([1-2]?[0-9]?[0-9]\.){3}([1-2]?[0-9]?[0-9])$ ]]; then
		return 0
	else
		return 1
	fi
}
