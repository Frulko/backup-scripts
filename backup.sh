#!/bin/bash
package="Backup"

dryrun=false
debug=false
exclude_file="./.rsync_exclude"
include_file="./.rsync_include"
target=""


if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "You must supply at least one argument. Use -h or --help for more information."
    exit 1
fi

# help flags https://stackoverflow.com/a/7069755
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "$package - attempt to backup folder"
      echo " "
      echo "$package [arguments]"
      echo " "
      echo "options:"
      echo "-h,  --help                show brief help"
      echo "-d,  --dryrun              dry run rsync + command and args"
      echo "-e,  --exclude=FILE        file that contain exclude files/folders (one per line)"
      echo "-i,  --include=FILE        file that contain files/folders to backup (one per line)"
      echo "-t,  --target=FILE         target folder to backup"
      echo "-dd, --debug               show debug variables"
      exit 0
      ;;
    -d|--dryrun)
      dryrun=true
      shift
      ;;
    -dd|--debug)
      debug=true
      shift
      ;;
    -e|--exclude)
      shift
      if test $# -gt 0; then
        export exclude_file=$1
      else
        echo "no output dir specified"
        exit 1
      fi
      shift
      ;;
    --exclude*)
      export exclude_file=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    -i|--include)
      shift
      if test $# -gt 0; then
        export include_file=$1
      else
        echo "no output dir specified"
        exit 1
      fi
      shift
      ;;
    --include*)
      export include_file=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    --target=*)
      export target=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    -t|--target)
      shift
      if test $# -gt 0; then
        export target=$1
      else
        echo "no target specified"
        exit 1
      fi
      shift
      ;;

    *)
      break
      ;;
  esac
done




get_exclude_files() {
  EXCLUDES=""

  if test -f "$exclude_file"; then
    # while IFS= read -r line
    # do
    #         # display $line or do somthing with $line
      
    #   EXCLUDES+=" --exclude='$line'"

    # done <"$exclude_file"
    # EXCLUDES+=" --exclude='$exclude_file'"
    EXCLUDES="--exclude-from='$exclude_file'"
  fi
  
  exclude_args=$EXCLUDES
}


# test folder : https://linuxize.com/post/bash-check-if-file-exists/
if [[ -z "$target" ]] | [[ ! -d "$target" ]]
then
  echo "no target specified or target $target not exist"
  exit 1
fi

if [[ ! -f "$include_file" ]]
then
  echo "INCLUDE: file $include_file not exist"
  exit 1
fi

if [[ ! -f "$exclude_file" ]]
then
  echo "EXCLUDE: file $exclude_file not exist"
  exit 1
fi


get_exclude_files

if [[ "$debug" == true ]]
then
  echo "Debug args:"
  echo "exclude_args - $exclude_args"
  echo "dryrun - $dryrun"
  echo "debug - $debug"
  echo "include_file - $include_file"
  echo "exclude_file - $exclude_file"
  exit 0
fi


if [[ "$dryrun" == true ]]
then
  dry_run_arg=' --dry-run'
else
  dry_run_arg=''
fi

while IFS= read -r line_include
do
  eval "rsync -auvhp --delete --progress$dry_run_arg $exclude_args $line_include $target_folder"

done <"$include_file"