#!/bin/bash

## Helper functions
usage() {
  cat <<EOT
    Generates manifest for assembly_unicycler_short_read nextflow pipeline using data stored centrally (visible to `pf`).

    Usage: $(basename $0) <OPTION>...

    Options:
        -i    Path to input file containing list of paths to fastq files to run through pipeline. (mandatory)
        -o    Path to output manifest file that will be generated. [default: manifest.csv] (optional)
        -h    Print this help message and exit the program

EOT
}

validate_filepath () {
  if [[ -f $1 ]]; then
    # FIXME path_valid isn't used
    # shellcheck disable=SC2034
    path_valid=true
  else
    echo "$1 is not a valid filepath!" >&2
    exit 1
  fi
}


## Arg parsing
if [[ "$#" == "0" ]]; then
  usage >&2
  exit 1
fi

while getopts "i:o:h" arg;
do
  case $arg in
    i) input_file="${OPTARG}";;
    o) manifest_file="${OPTARG}";;
    h) usage; exit 0;;
    *) echo "Unrecognised option ${OPTARG} will be ignored" 1>&2
  esac
done

if  [ ! ${input_file} ]; then
  echo "input file (-i) containing fastq paths is a mandatory argument, please ensure it is supplied using: -i <input_file>" >&2
  echo >&2
  usage >&2
  exit 1
else
  validate_filepath ${input_file}
fi

if  [ ! ${manifest_file} ]; then
  manifest_file="manifest.csv"
fi


## Main
fastq_paths="${input_file}"
count=0
echo "ID,R1,R2" > "${manifest_file}"

while read line
do
  let count=count+1
  if [ $count -eq 2 ]
    then
      lane_id=$(echo $line | awk -F "/" '{ print $NF }' | sed 's|_[12].fastq.gz||g')
      read2=$(echo $line)
      read1=$(cat $fastq_paths | grep ${lane_id}_ | grep -v ${read2})
      echo $lane_id,$read1,$read2 >> "${manifest_file}"
      count=0
    fi
done < $fastq_paths

