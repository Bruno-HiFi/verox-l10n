#!/bin/bash

tmpdir=$( mktemp -d /tmp/check_lang.XXXXX )

DEBUG=0
MASTER="en-US.json"
WARNING=0
TODO=0

if [ "$1" = "todo" ]
then
   echo "create TODO file"
   TODO=1
fi

bold=$(tput bold)
normal=$(tput sgr0)

_debug()
{
   test -z DEBUG && return 0
   test $DEBUG -eq 0 && return 0

   echo "DEBUG: $@"
}

_abort()
{
   echo "ERROR: $@"
   exit 1
}

_warning()
{
   echo "WARNING: $@"
   (( WARNING = WARNING + 1 ))
   _debug "warning count: $WARNING"
}

_todo()
{
   test $TODO -eq 0 && return

   local lang=$1
   local section=$2
   local key=$3
   local issue=$4

   printf '%s\t%s\t%s\t%s\n' "$lang" "$section" "$key" "$issue" >> $todo_rows
}

# write the collected rows as a single markdown table, columns padded to equal width
_write_todo_table()
{
   {
      printf 'Language\tSection\tKey\tIssue\n'
      cat $todo_rows
   } | awk -F'\t' '
      { for (i = 1; i <= NF; i++) { cell[NR, i] = $i; if (length($i) > w[i]) w[i] = length($i) } }
      END {
         for (r = 1; r <= NR; r++) {
            line = "|"
            for (i = 1; i <= 4; i++) line = line sprintf(" %-" w[i] "s |", cell[r, i])
            print line
            if (r == 1) {
               line = "|"
               for (i = 1; i <= 4; i++) { d = ""; for (j = 0; j < w[i]; j++) d = d "-"; line = line " " d " |" }
               print line
            }
         }
      }' >> $todo_file
}

is_valid_json_file()
{
   local f=$1

   cat $f | jq empty > /dev/null 2>&1
   if [ $? -ne 0 ]
   then
      return 1
   else
      return 0
   fi
}

check_for_missing_keys()
{
   local f=$1
   local lang=$( basename $f .json )
   local issues=0

   if [ ! -r $f ]
   then
      _abort "can't open file $f"
   fi

   if ! is_valid_json_file $f
   then
      _abort "not a valid json file: ${bold}$( basename $f )${normal}"
   fi

   # iterate over the toplevel keys
   while read k
   do
      _debug "checking toplevel key $k"

      # does this toplevel key even exist?
      if [ $( cat $f | jq -r 'keys_unsorted[]' | grep -cxF -- "$k" ) -eq 0 ]
      then
         _warning "toplevel key $k not found in ${bold}$( basename $f )${normal}"
	 _todo "$lang" "$k" "(whole section)" "missing"
	 ((issues = issues + 1))
      else
         # the toplevel key exists, now let's check the subkeys
         while read l
	 do
            _debug "checking toplevel key $k, sublevel key $l"
            sk=$( cat $f | jq -r ".${k} | .${l}" )
            if [ "$sk" = "null" ]
            then
               _warning "key $k, sublevel key $l not found in ${bold}$( basename $f )${normal}"
               _todo "$lang" "$k" "$l" "missing"
	       ((issues = issues + 1))
            else
               # subkey exists, but make sure it's not empty
               if [ -z "$sk" ]
               then
                  _warning "key $k, sublevel key $l found, but empty in ${bold}$( basename $f )${normal}"
                  _todo "$lang" "$k" "$l" "empty"
	          ((issues = issues + 1))
               fi
            fi
         done < <( cat en-US.json| jq -r ".${k} | keys_unsorted[]" )
      fi
   done < <( cat $MASTER | jq -r 'keys_unsorted[]' )

   # let's do a reverse check: does the translation file has keys
   # that don't exist at all (in the master file)

   cat $f | jq -r 'keys_unsorted[]' |
   while read k
   do
      _debug "reverse checking toplevel key $k"

      # does this toplevel key even exist?
      if [ $( cat $MASTER | jq -r 'keys_unsorted[]' | grep -cxF -- "$k" ) -eq 0 ]
      then
         echo "ERROR: ${bold}$( basename $f )${normal}: toplevel $k not found in MASTER"
      else
         # the toplevel key exists, now let's check the subkeys
	 cat $f | jq -r ".${k} | keys_unsorted[]" |
         while read l
	 do
            _debug "reverse checking toplevel key $k, sublevel key $l"
	    if [ $( cat $MASTER | jq -r ".${k} | keys_unsorted[]" | grep -cxF -- "$l" ) -eq 0 ]
	    then
               echo "ERROR: ${bold}$( basename $f )${normal}: key $k, sublevel key $l not found in MASTER"
	    fi
	 done
      fi
   done

   return $issues
}

########################################################################################################################
########################################################################################################################

# do we have jq?
type jq >/dev/null 2>&1
if [ $? -ne 0 ]
then
   _abort "can't find 'jq' executable"
fi

# do we need to create a 'todo' file?
if [ $TODO -eq 1 ]
then
   todo_file=$tmpdir/todo.md
   todo_rows=$tmpdir/todo.rows
   : > $todo_rows
   echo "## TODO missing (sub)keys"                >> $todo_file
   echo                                            >> $todo_file
   echo "> [!WARNING]"                             >> $todo_file
   echo "> This file is generated, do *not* edit!" >> $todo_file
   echo                                            >> $todo_file
   echo                                            >> $todo_file
   echo "The following (sub)keys are missing:"     >> $todo_file
   echo                                            >> $todo_file
fi

# iterate over all files (except master)
for file in $( ls ./*.json | grep -v $MASTER )
do
   echo
   echo "found language file: ${bold}$( basename $file )${normal}"
   check_for_missing_keys $file
   nr=$?

   if [ $nr -eq 0 ]
   then
      echo "no issues found!"
      _todo "$( basename $file .json )" "" "" "up to date"
   fi
done

_debug "warning counts: $WARNING"
if [ $WARNING -eq 0 ]
then
   echo
   echo "Everything looks OK!"
else
   echo
   echo "Please fix the warnings..."
fi

if [ $TODO -eq 1 ]
then
   echo
   echo "TODO file created/updated!"
   _write_todo_table
   _debug "tmp TODO file: $todo_file"
   cp $todo_file ./TODO.md
fi

rm -rf $tmpdir

exit 0
