#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2155

set -o errexit
set -o pipefail
set -o nounset

function write_log() {
	local message=$1
	local prefix=${2:-'\e[1;35m>>>\e[22;39m '}
	local suffix=${3:-''}

	printf '%b%b%b\n' "${prefix}" "${message}" "${suffix}"
}

function throw() {
	local message=${1:-'An error occurred!'}
	local function_name=${2:-${FUNCNAME[1]}}

	write_log "ERROR in '${function_name}()': ${message}"
	exit 1
}

function assert_args_count() {
	local -i args_count=$1
	local -i expected_args_count=$2

	if (( args_count >= expected_args_count )); then
		return 0
	fi

	throw \
		"Expected at least ${expected_args_count} arguments, but got only ${args_count}!" \
		"${FUNCNAME[1]}"
}

function assert() {
	assert_args_count "${#}" 1

	local condition=$1
	local error_message=${2:-'Assertion failed!'}

	if (( ! condition )); then
		return 0
	fi

	throw "${error_message}" "${FUNCNAME[1]}"
}

function get_repr() {
	assert_args_count "${#}" 1

	local value=$1

	printf '%q' "${value}"
}

function write_variable() {
	assert_args_count "${#}" 1

	local name=$1

	declare -p "${name}"
}

function command_exists() {
	assert_args_count "${#}" 1

	local command=$1

	command -v "${command}" &> '/dev/null'
}

function assert_command_exists() {
	assert_args_count "${#}" 1

	local command=$1

	if command_exists "${command}"; then
		return 0
	fi

	local message=${2:-"Command '${command}' not found!"}

	throw "${message}" "${FUNCNAME[1]}"
}

declare script_path=${BASH_SOURCE[0]:-$0}
declare script_dir=$(dirname "${script_path}")
cd "${script_dir}"

clear

declare bun_command='bun'
declare node_modules_dir='./node_modules'
declare source_dir='./src'
declare output_dir='./build'

assert_command_exists "${bun_command}" "$(printf \
	'ERROR: Bun is not installed! (Visit \e[1;34m%s\e[0m to download it)\n' \
	'https://bun.sh'
)"

if [[ ! -d "${node_modules_dir}" ]]; then
	write_log "$(printf \
		'MESSAGE: Directory "%q" does not exists, running `bun install`...' \
		"${node_modules_dir}"
	)"

	"${bun_command}" install
fi

exec "${bun_command}" \
	build \
	--outdir "${output_dir}" \
	--watch \
	-- \
	"${source_dir}"/**/*.ts
