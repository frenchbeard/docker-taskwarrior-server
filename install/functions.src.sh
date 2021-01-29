#! /bin/bash
# Modeline and description {{{
# Utilities functions for other runtime scripts
# vim: set sw=4 ts=4 sts=4 tw=78 ft=sh foldmarker={{{,}}} foldmethod=marker :
# }}}

# {{{ ver_cmp : Compares two version strings `a` and `b`
# Expected version format for a and b : X[.X[.X[.X]]]
# Returns
#   - negative integer, if `a` is less than `b`
#   - 0, if `a` and `b` are equal
#   - non-negative integer, if `a` is greater than `b`
ver_cmp() {
    expr '(' "$1" : '\([^.]*\)' ')' '-' '(' "$2" : '\([^.]*\)' ')' '|' \
        '(' "$1.0" : '[^.]*[.]\([^.]*\)' ')' '-' '(' "$2.0" : '[^.]*[.]\([^.]*\)' ')' '|' \
        '(' "$1.0.0" : '[^.]*[.][^.]*[.]\([^.]*\)' ')' '-' '(' "$2.0.0" : '[^.]*[.][^.]*[.]\([^.]*\)' ')' '|' \
        '(' "$1.0.0.0" : '[^.]*[.][^.]*[.][^.]*[.]\([^.]*\)' ')' '-' '(' "$2.0.0.0" : '[^.]*[.][^.]*[.][^.]*[.]\([^.]*\)' ')'
    } # }}}

## {{{ exec_as : Execute a command as TASKD_USER
# Returns command returned by the execution
exec_as() {
    if [[ $(whoami) == "${TASKD_USER}" ]]; then
        "$@"
    else
        sudo -HEu "${TASKD_USER}" "$@"
    fi
}
# }}}
