#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "iSphinx.h"
#import "cmdln_macro.h"
#import "pocketsphinx.h"
#import "pocketsphinx_export.h"
#import "ps_lattice.h"
#import "ps_mllr.h"
#import "ps_search.h"
#import "ad.h"
#import "agc.h"
#import "bio.h"
#import "bitvec.h"
#import "byteorder.h"
#import "case.h"
#import "ckd_alloc.h"
#import "clapack_lite.h"
#import "cmd_ln.h"
#import "cmn.h"
#import "err.h"
#import "f2c.h"
#import "fe.h"
#import "feat.h"
#import "filename.h"
#import "fixpoint.h"
#import "fsg_model.h"
#import "genrand.h"
#import "glist.h"
#import "hash_table.h"
#import "heap.h"
#import "huff_code.h"
#import "jsgf.h"
#import "listelem_alloc.h"
#import "logmath.h"
#import "matrix.h"
#import "mmio.h"
#import "mulaw.h"
#import "ngram_model.h"
#import "pio.h"
#import "prim_type.h"
#import "profile.h"
#import "sbthread.h"
#import "sphinxbase_export.h"
#import "sphinx_config.h"
#import "strfuncs.h"
#import "yin.h"

FOUNDATION_EXPORT double iSphinxVersionNumber;
FOUNDATION_EXPORT const unsigned char iSphinxVersionString[];

