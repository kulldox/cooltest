#!/bin/bash

APPDIR="$(cd $(dirname $0) && pwd)";


iTestClass="${1}";
iTestCase="${2}";
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <testFile.rb> <testCase>";
  echo "<testFile.rb> - the input file from tests/*.rb that you want to execute a test from";
  echo "<testCase> - the actual test case from the input file";
  echo;
  echo "Example: $0 TC_demo.rb test_TC_demo_01";
  echo;
  echo "The output will be saved in 'log/TC_demo.rb_$(date +'%Y-%m-%d-%H%M').txt'";

  exit 1;
fi;

cd ${APPDIR}

ifile="${APPDIR}/tests/${iTestClass}";
if [ ! -f "${ifile}" ]; then
    echo "ERROR: File '${ifile}'not found! Exit."; exit 1;
fi;

echo "$(date +'%Y-%m-%d %H:%M:%S') INFO: Starting '${iTestCase}' from '${ifile}'."

ruby  tests/${iTestClass} --name ${iTestCase} 2>&1 | tee -a log/${iTestClass}_${iTestCase}_$(date +'%Y-%m-%d-%H%M').txt

echo "$(date +'%Y-%m-%d %H:%M:%S') INFO: Done '${iTestCase}' from '${ifile}'."
