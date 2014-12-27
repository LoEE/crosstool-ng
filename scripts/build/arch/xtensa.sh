CT_DoArchTupleValues() {
    :
}

# This function updates the specified component (binutils, gcc, gdb, etc.)
# with the processor specific configuration.
CT_ConfigureXtensa() {
    local component="${1}"
    local version="${2}"
    local custom_config="${CT_ARCH_XTENSA_CUSTOM_OVERLAY_FILE}"
    local custom_location="${CT_ARCH_XTENSA_CUSTOM_OVERLAY_LOCATION}"

    local full_file="${CT_TARBALLS_DIR}/${custom_config}"
    local basename="${component}-${version}"

    CT_TestAndAbort "${custom_config}: CT_CUSTOM_LOCATION_ROOT_DIR or CT_ARCH_XTENSA_CUSTOM_OVERLAY_LOCATION must be set." \
        -z "${CT_CUSTOM_LOCATION_ROOT_DIR}" -a -z "${custom_location}"

    if [ -n "${CT_CUSTOM_LOCATION_ROOT_DIR}" -a -z "${custom_location}" ]; then
        custom_location="${CT_CUSTOM_LOCATION_ROOT_DIR}"
    fi

    if [ -e "${CT_SRC_DIR}/.${basename}.configuring" ]; then
        CT_DoLog ERROR "The '${basename}' source were partially configured."
        CT_DoLog ERROR "Please remove first:"
        CT_DoLog ERROR " - the source dir for '${basename}', in '${CT_SRC_DIR}'"
        CT_DoLog ERROR " - the file '${CT_SRC_DIR}/.${basename}.extracted'"
        CT_DoLog ERROR " - the file '${CT_SRC_DIR}/.${basename}.patch'"
        CT_DoLog ERROR " - the file '${CT_SRC_DIR}/.${basename}.configuring'"
        CT_Abort
    fi

    CT_DoLog DEBUG "Using '${custom_config}' from ${custom_location}"
    CT_DoExecLog INFO ln -sf "${custom_location}/${custom_config}" \
        "${CT_TARBALLS_DIR}/${custom_config}"

    CT_DoExecLog DEBUG touch "${CT_SRC_DIR}/.${basename}.configuring"

    CT_Pushd "${CT_SRC_DIR}/${basename}"

    tar_opts=( "--strip-components=1" )
    tar_opts+=( "-xv" )

    CT_DoLog DEBUG "Extracting ${full_file} for ${component}"
    CT_DoExecLog FILE tar "${tar_opts[@]}" -f "${full_file}" "${component}"

    CT_DoExecLog DEBUG touch "${CT_SRC_DIR}/.${basename}.configured"
    CT_DoExecLog DEBUG rm -f "${CT_SRC_DIR}/.${basename}.configuring"

    CT_Popd
}
