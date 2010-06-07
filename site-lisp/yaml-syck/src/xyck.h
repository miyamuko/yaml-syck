/* -*- mode: c: indent-tabs-mode: nil -*- */

/*
 * File: yaml-syck/xyck.h
 *
 *   Copyright (c) 2007 MIYAMUKO Katsuyuki.
 *
 *   See yaml-syck/docs/MIT-LICENSE for full license.
 */

#ifndef XYCK_H
#define XYCK_H


#define STDCALL __attribute__ ((stdcall))
#define APIENTRY STDCALL
#define CALLBACK STDCALL

#include "syck.h"

#if defined(__cplusplus)
extern "C" {
#endif


int APIENTRY xyck_yaml_major();
int APIENTRY xyck_yaml_minor();

const char* APIENTRY xyck_version();
const char* APIENTRY xyck_yaml_domain();

int APIENTRY xyck_eof(SyckParser* parser);
int APIENTRY xyck_linect(SyckParser* parser);

char* APIENTRY xyck_cursor(SyckParser* parser);
char* APIENTRY xyck_lineptr(SyckParser* parser);


#if defined(__cplusplus)
}  /* extern "C" { */
#endif

#endif /* ifndef XYCK_H */
