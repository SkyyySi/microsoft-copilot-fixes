#!/usr/bin/env bash
# shellcheck disable=SC2016

cd "$(dirname "${BASH_SOURCE[0]:-$0}")" || exit 1

if ! command -v bun > '/dev/null'; then
	printf \
		'ERROR: Bun is not installed! (Visit \e[1;34m%s\e[0m to download it)\n' \
		'https://bun.sh'

	exit 1
fi

clear

declare node_modules_dir='./node_modules'
declare source_dir='./src'
declare output_dir='./build'

if [[ ! -d "${node_modules_dir}" ]]; then
	printf \
		'MESSAGE: Directory "%q" does not exists, running `bun install`...' \
		"${node_modules_dir}"

	bun install
fi

bun \
	build \
	--outdir "${output_dir}" \
	--watch \
	-- \
	"${source_dir}"/**/*.ts
