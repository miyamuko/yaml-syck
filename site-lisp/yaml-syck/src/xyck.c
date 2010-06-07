/* -*- mode: c: indent-tabs-mode: nil -*- */

/*
 * File: yaml-syck/xyck.c
 *
 *   Copyright (c) 2007 MIYAMUKO Katsuyuki.
 *
 *   See yaml-syck/docs/MIT-LICENSE for full license.
 */

#include "syck.h"
#include "xyck.h"


APIENTRY
int
xyck_yaml_major() {
    return SYCK_YAML_MAJOR;
}

APIENTRY
int
xyck_yaml_minor() {
    return SYCK_YAML_MINOR;
}

APIENTRY
const char*
xyck_version() {
    return SYCK_VERSION;
}

APIENTRY
const char*
xyck_yaml_domain() {
    return YAML_DOMAIN;
}

APIENTRY
int
xyck_eof(SyckParser* parser) {
    return parser->eof;
}

APIENTRY
int
xyck_linect(SyckParser* parser) {
    return parser->linect;
}

APIENTRY
char*
xyck_cursor(SyckParser* parser) {
    return parser->cursor;
}

APIENTRY
char*
xyck_lineptr(SyckParser* parser) {
    return parser->lineptr;
}
