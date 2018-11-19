#!/usr/bin/env bash
#########################################
## apk2src.sh - APK Reversing Script 
##
## Author: ghimire
## License: GNU GPL v3.0
##
#########################################

if [ ${#} -lt 1 ]; then
    echo "Usage $0 <path to apkfile>";
fi
starttime=$(date +%s)
apkfilepath=${1}

[[ ${apkfilepath} =~ \.apk$ ]] || exit 0
[[ -f ${apkfilepath} ]] || exit 0

basepath=$(pwd)
[[ -d ${basepath} ]] || exit 0

dex2jardir="tools/dex2jar"
jdcoredir="tools/jd-core-java"
projectsample="tools/project_sample"

tmppath=$$
rm -rf ${tmppath}
mkdir ${tmppath}
apkfile=$(basename ${apkfilepath})
packagename=$(echo ${apkfile} | sed 's/.apk$//')
logfile=${basepath}/log/${packagename}.log
mkdir -p ${basepath}/log

colorreset="[0m"
colorblue="[34;1m"
colorred="[31;1m"
colorgreen="[32;1m"

echo -e "${colorred}== $(date) Processing ${packagename} == ${colorreset}" >> ${logfile} 2>&1
echo -e "${colorblue}$(date)${colorgreen} Copying ${apkfilepath} to ${basepath}/${tmppath} ${colorreset}" >> ${logfile} 2>&1
cp ${apkfilepath} ${basepath}/${tmppath}
cd ${basepath}/${tmppath}

echo -e "${colorblue}$(date)${colorgreen} Unzipping ${apkfile} ${colorreset}" >> ${logfile} 2>&1
unzip -qq ${apkfile} >> ${logfile} 2>&1

echo -e "${colorblue}$(date)${colorgreen} Converting ${basepath}/${tmppath}/classes.dex to Jar ${colorreset}" >> ${logfile} 2>&1
../${dex2jardir}/d2j-dex2jar.sh ${basepath}/${tmppath}/classes.dex >> ${logfile} 2>&1

echo -e "${colorblue}$(date)${colorgreen} Decompiling ${basepath}/${tmppath}/classes_dex2jar.jar ${colorreset}" >> ${logfile} 2>&1
cd ${basepath}/${jdcoredir}/
# Copy processor dependent libjd-intellij.so to ${basedir}
arch=x86_64
[[ $(echo $(uname -m)) =~ x86_64 ]] || arch=x86
cp jd-intellij/${arch}/libjd-intellij.so ./
java -jar jd-core-java-1.0.jar ${basepath}/${tmppath}/classes-dex2jar.jar ${basepath}/${tmppath}/decompiled >> ${logfile} 2>&1

echo -e "${colorblue}$(date)${colorgreen} Reversing ${apkfile} with apktool ${colorreset}" >> ${logfile} 2>&1
cd ${basepath}
apktool -q d ${apkfile} >> ${logfile} 2>&1

echo -e "${colorblue}$(date)${colorgreen} Creating ${packagename}/src ${colorreset}" >> ${logfile} 2>&1
mkdir -p ${basepath}/${packagename}/src

echo -e "${colorblue}$(date)${colorgreen} Copying ${tmppath}/decompiled/ to ${packagename}/src ${colorreset}" >> ${logfile} 2>&1
cp -r ${tmppath}/decompiled/* ${packagename}/src

echo -e "${colorblue}$(date)${colorgreen} Copying project file ${colorreset}" >> ${logfile} 2>&1
cat ${basepath}/${projectsample} | sed 's/INSERTNAME/'${packagename}'/' > ${packagename}/.project

echo -e "${colorblue}$(date)${colorgreen} Removing ${tmppath} ${packagename}/apktool.yml ${packagename}/smali/ ${colorreset}" >> ${logfile} 2>&1
rm -rf ${tmppath} ${packagename}/apktool.yml ${packagename}/smali/

echo -e "${colorblue}$(date)${colorgreen} Removing R.java, BuildConfig.java ${colorreset}" >> ${logfile} 2>&1
find ${basepath}/${packagename} -type f -name "R.java" -exec rm {} \;
find ${basepath}/${packagename} -type f -name "BuildConfig.java" -exec rm {} \;

echo -e "${colorblue}$(date)${colorgreen} Creating ${packagename}.tar.bz2 ${colorreset}" >> ${logfile} 2>&1
tar -cjf ${packagename}.tar.bz2 ${packagename} >> ${logfile} 2>&1

echo -e "${colorblue}$(date)${colorgreen} Removing ${packagename} ${apkfile} ${colorreset}" >> ${logfile} 2>&1
rm -rf ${packagename}
endtime=$(date +%s)

echo -e -e "${colorred}== $(date) Finished processing ${packagename} in $(( $endtime - $starttime ))s == ${colorreset}\n" >> ${logfile} 2>&1
# All done, check logs.
