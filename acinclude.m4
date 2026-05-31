dnl Function to test if a certain feature was enabled
AC_DEFUN([AX_COMMON_ARG_ENABLE],
  [AC_ARG_ENABLE(
    [$1],
    [AS_HELP_STRING(
      [--enable-$1],
      [$3 @<:@default=$4@:>@])],
    [ac_cv_enable_$2=$enableval],
    [ac_cv_enable_$2=$4])dnl
    
    AC_CACHE_CHECK(
      [whether to enable $3],
      [ac_cv_enable_$2],
      [ac_cv_enable_$2=$4])dnl
  ])

dnl Function to check if asan can be used for testing
AC_DEFUN([AX_TESTS_CHECK_ASAN_BUILD],
  [AC_MSG_CHECKING([whether asan can be used for testing])

  BACKUP_CFLAGS="$CFLAGS"
  BACKUP_LDFLAGS="$LDFLAGS"

  ASAN_CFLAGS="-fno-omit-frame-pointer -fsanitize=address -g -O0"
  ASAN_LDFLAGS="-fsanitize=address"

  CFLAGS="$CFLAGS $ASAN_CFLAGS"
  LDFLAGS="$LDFLAGS $ASAN_LDFLAGS"

  AC_LANG_PUSH(C)

  AC_RUN_IFELSE(
    [AC_LANG_PROGRAM(
      [[#include <stdlib.h>]],
      [[char *array = (char *) malloc(10 * sizeof(char));
if (array == NULL) { return 0; }
array[10] = 42;
free(array);]] )],
      [ac_cv_have_asan=no],
      [ac_cv_have_asan=yes],
      [ac_cv_have_asan=undetermined])

  AC_LANG_POP(C)

  CFLAGS="$BACKUP_CFLAGS"
  LDFLAGS="$BACKUP_LDFLAGS"

  AC_MSG_RESULT(
    [$ac_cv_have_asan])
  ])

dnl Function to check whether libubsan is functional
AC_DEFUN([AX_TESTS_CHECK_LIBUBSAN],
  [AC_MSG_CHECKING([whether libubsan is functional])

  BACKUP_CFLAGS="$CFLAGS"
  BACKUP_LDFLAGS="$LDFLAGS"

  UBSAN_CFLAGS="-fsanitize=undefined -O0"
  UBSAN_LDFLAGS="-fsanitize=undefined"

  CFLAGS="$CFLAGS $UBSAN_CFLAGS"
  LDFLAGS="$LDFLAGS $UBSAN_LDFLAGS"

  AC_LANG_PUSH(C)

  AC_LINK_IFELSE(
    [AC_LANG_PROGRAM(
      [[#include <stdio.h>]]
      [[int shift = 1;
int negative = -5;
int result = (negative << shift);]] )],
      [ac_cv_have_ubsan=no],
      [ac_cv_have_ubsan=yes],
      [ac_cv_have_ubsan=undetermined])

  AC_LANG_POP(C)

  CFLAGS="$BACKUP_CFLAGS"
  LDFLAGS="$BACKUP_LDFLAGS"

  AC_MSG_RESULT(
    [$ac_cv_have_asan])
  ])

dnl Function to detect whether asan support should be enabled
AC_DEFUN([AX_TESTS_CHECK_ENABLE_ASAN],
  [AX_COMMON_ARG_ENABLE(
    [asan],
    [asan],
    [build with asan)],
    [no])

  ac_cv_have_asan=no

  AS_IF(
    [test "x$ac_cv_enable_asan" != xno],
    [AX_TESTS_CHECK_ASAN_BUILD

    AS_IF(
      [test "x$ac_cv_have_asan" = xno],
      [AC_MSG_FAILURE(
        [Unable to build with functional asan],
        [1])
      ])

    CFLAGS="$CFLAGS $ASAN_CFLAGS"
    CXXFLAGS="$CXXFLAGS $ASAN_CFLAGS"
    LDFLAGS="$LDFLAGS $ASAN_LDFLAGS"
    ])
  ])

dnl Function to detect whether ubsan support should be enabled
AC_DEFUN([AX_TESTS_CHECK_ENABLE_UBSAN],
  [AX_COMMON_ARG_ENABLE(
    [ubsan],
    [ubsan],
    [build with ubsan)],
    [no])

  ac_cv_have_ubsan=no

  AS_IF(
    [test "x$ac_cv_enable_ubsan" != xno],
    [AX_TESTS_CHECK_LIBUBSAN

    AS_IF(
      [test "x$ac_cv_have_ubsan" = xno],
      [AC_MSG_FAILURE(
        [Unable to build with functional libubsan],
        [1])
      ])

    CFLAGS="$CFLAGS $UBSAN_CFLAGS -fno-sanitize-recover=undefined"
    CXXFLAGS="$CXXFLAGS $UBSAN_CFLAGS -fno-sanitize-recover=undefined"
    LDFLAGS="$LDFLAGS $UBSAN_LDFLAGS -fno-sanitize-recover=undefined"
    ])
  ])
