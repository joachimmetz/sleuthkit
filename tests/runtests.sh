#!/bin/bash

# NOTE: This script is not currently being used anywhere. 
# it curently runs fs_thread_test on a set of images that
# are not public
#
# This could probably be renamed to something with threadtest in the name


EXIT_SUCCESS=0;
EXIT_FAILURE=1;
EXIT_IGNORE=77;

IMAGE_DIR=${HOME}/from_brian
NTHREADS=1
NITERS=1

check_diffs()
{
	for LOG_FILE in thread-*.log;
	do
		echo diff base.log ${LOG_FILE};
		diff base.log ${LOG_FILE} || return ${EXIT_FAILURE};
	done;

	return ${EXIT_SUCCESS};
}

if ! test -d ${IMAGE_DIR};
then
	echo "Missing image directory: ${IMAGE_DIR}";

	exit ${EXIT_IGNORE};
fi

FS_THREAD_TEST="./fs_thread_test";

if ! test -x ${FS_THREAD_TEST};
then
	FS_THREAD_TEST="./fs_thread_test.exe";
fi

if ! test -x ${FS_THREAD_TEST};
then
	echo "Missing test executable: ${IMAGE_DIR}";

	exit ${EXIT_IGNORE};
fi

for FILE in ${IMAGE_DIR}/*
do
	rm -f base.log thread-*.log
	${FS_THREAD_TEST} ${IMAGE_DIR}/ext2fs.dd 1 1
	mv thread-0.log base.log
	${FS_THREAD_TEST} ${IMAGE_DIR}/ext2fs.dd ${NTHREADS} ${NITERS}

	if ! check_diffs;
	then
		exit ${EXIT_FAILURE};
	fi
done

exit ${EXIT_SUCCESS};

