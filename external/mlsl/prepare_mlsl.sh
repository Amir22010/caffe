#!/bin/sh
# set -ex
# 
# All modification made by Intel Corporation: © 2016 Intel Corporation
# 
# This script is used to prepare the Intel® Machine Learning Scaling Library
#
FindLibrary()
{
# Find all the instances of the MKL libraries present in Caffe
  MLSL_LIBS=`find $1 -name libmlsl.so`
  #echo "[Debug][FindLibrary function] MLSL_LIBS: $MLSL_LIBS"

  LOCALMLSL=$MLSL_LIBS
  #echo "[Debug][FindLibrary function] LOCALMLSL: $LOCALMLSL"
}

GetVersionName()
{
VERSION_LINE=0
if [ $1 ]; then
  RAW_VERSION_LINE=`echo $1 | rev | cut -d "_" -f -1 | rev`
  VERSION_LINE=`echo $RAW_VERSION_LINE | sed 's/\.//g'`
fi
if [ -z $VERSION_LINE ]; then
  VERSION_LINE=0
fi
echo $VERSION_LINE  # Return Version Line
}

# MLSL
DST=`dirname $0`
#echo "[Debug] dirname: $0"
#echo "[Debug] DST value: $DST"
ABS_DST=`readlink -f $DST`
#echo "[Debug] ABS_DST value: $ABS_DST"
VERSION_MATCH=20170014
ARCHIVE_BASENAME=l_mlsl_p_2017.0.014.tgz
ARCHIVE_INSTALL_FOLDERNAME=l_mlsl_p_2017.0.014
MLSL_CONTENT_DIR=`echo $ARCHIVE_BASENAME | rev | cut -d "." -f 2- | rev`
#echo "[Debug] MLSL_CONTENT_DIR value: $MLSL_CONTENT_DIR"
GITHUB_RELEASE_TAG=v2017-Preview

MLSLURL="https://github.com/01org/MLSL/releases/download/$GITHUB_RELEASE_TAG/$ARCHIVE_BASENAME"
#echo "[Debug] MLSLROOT value: $MLSLROOT"
VERSION_LINE=`GetVersionName $MLSLROOT`
#echo "[Debug] VERSION_LINE value: $VERSION_LINE"
# Check if MLSLROOT is set if positive then set one will be used..
if [ -z $MLSLROOT ] || [ $VERSION_LINE -lt $VERSION_MATCH ]; then
  # ..if MLSLROOT is not set then check if we have MLSL unpacked and installed in proper version
  FindLibrary $DST
  #echo "[Debug] LOCALMLSL value inside if: $LOCALMLSL"
  if [ $LOCALMLSL ]; then
    #in order to return value to calling script (Makefile,cmake), cannot print other info
    #echo "[Debug] Some verison of MLSL is unpacked and installed"
    MLSL_PREVIOUS_CONTENT_DIR=`echo $LOCALMLSL | rev | cut -d "/" -f 4- | cut -d "/" -f -1 | rev`
    VERSION_LINE=`GetVersionName $DST/$MLSL_PREVIOUS_CONTENT_DIR`
  fi
  #echo "[Debug] VERSION_LINE value inside if: $VERSION_LINE"
  #if MLSLROOT is set, but version is not given, not to download our own version
  if [ -z $MLSLROOT ] && [ $VERSION_LINE -lt $VERSION_MATCH ] ; then
    #...If it is not then downloaded, unpacked and installed
    wget --no-check-certificate -P $DST $MLSLURL -O $DST/$ARCHIVE_BASENAME
    tar -xzf $DST/$ARCHIVE_BASENAME -C $DST
    #echo "[Debug] PWD value: $PWD"
    #install.sh did not support the relative path as the parameter
    bash $DST/install.sh -s -d $ABS_DST/$ARCHIVE_INSTALL_FOLDERNAME
	
    #do not change the value of MLSLROOT if MLSLROOT is set, but version is not given
    FindLibrary $DST
    #echo "[Debug] LOCALMLSL value: $LOCALMLSL"
    #echo "[Debug] PWD value: $PWD"
    MLSLROOT=$PWD/`echo $LOCALMLSL | sed -e 's/intel64.*$//'`
  fi
  #echo "[Debug] MLSLROOT value: $MLSLROOT"
fi

if [ -z $LOCALMLSL ] ; then
# LOCALMLSL is not set, when MLSLROOT was set manually and it should point to MLSL in correct version
  FindLibrary $MLSLROOT
  LIBRARIES=""
else
  LIBRARIES=`basename $LOCALMLSL | sed -e 's/^.*lib//' | sed -e 's/\.so.*$//'`  
fi
    
#echo "[Debug] LIBRARIES value: $LIBRARIES"

# return value to calling script (Makefile,cmake)
echo $MLSLROOT $LIBRARIES