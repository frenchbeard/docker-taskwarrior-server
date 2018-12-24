/* cmake.h.in. Creates cmake.h during a cmake run */

/* Product identification */
#define PRODUCT_TASKSERVER 1

/* Feature enable/disabled */
#define FEATURE_CLIENT_INTERFACE

/* Package information */
#define PACKAGE           "taskd"
#define VERSION           "1.1.0"
#define PACKAGE_BUGREPORT "support@taskwarrior.org"
#define PACKAGE_NAME      "taskd"
#define PACKAGE_TARNAME   "taskd"
#define PACKAGE_VERSION   "1.1.0"
#define PACKAGE_STRING    "taskd 1.1.0"

#define CMAKE_BUILD_TYPE  ""

/* Installation details */
#define TASKD_EXTDIR "/usr/local/libexec/taskd"

/* Localization */
#define PACKAGE_LANGUAGE  1
#define LANGUAGE_ENG_USA 1

/* git information */
#define HAVE_COMMIT

/* cmake information */
#define HAVE_CMAKE
#define CMAKE_VERSION "2.8.11.1"

/* Compiling platform */
/* #undef LINUX */
#define DARWIN
/* #undef CYGWIN */
/* #undef FREEBSD */
/* #undef OPENBSD */
/* #undef NETBSD */
/* #undef HAIKU */
/* #undef SOLARIS */
/* #undef KFREEBSD */
/* #undef GNUHURD */
/* #undef UNKNOWN */

/* Found tm.tm_gmtoff struct member */
#define HAVE_TM_GMTOFF

/* Found st.st_birthtime struct member */
#define HAVE_ST_BIRTHTIME

/* Functions */
#define HAVE_TIMEGM
#define HAVE_UUID_UNPARSE_LOWER

/* Libraries */
#define HAVE_LIBGNUTLS

