#!/usr/bin/env ksh93
#Author: G. Clifford Williams
#email: gcw-ksh93@notadiscussion.com
#Purpose: This is a simple producer/consumer example written in KSH93 to
#   demonstrate parallel execution with discreet I/O.
#   
#Note: This example script requires KSH93. It will not work with BASH, PDKSH,
#   MKSH, ZSH, KSH88, etc. Further it incorporates features foun in version r+
#   and later. KSH93 u+ has been around for 5 years and is the version I used
#   but your mileage may vary. 

typeset -a inputs=()
typeset -a outputs=()
set +o bgnice

for counter in {A..F}{0..9} ; do
  #create a background job that has output on it's STDOUT at a random interval
  { while true ; do 
      #print -n "pump ${counter}: $(date)" >> ${my_file}
      integer sleep_time=$(( $(( $RANDOM + 1 )) / 32768.0 * 5 )) 
      printf "pump %s/%i: %(%H:%M:%S)T\n" ${counter} ${sleep_time} now 
      sleep ${sleep_time}
    done
  }|&
  # The '|&' above is how ksh launches a co-process in the background with 
  # bi-directional I/O. We wrap everything in a command-list ({;}) for clarity
        
  #The bit below can seem confusing. The co-process produces output which is 
  #input to the consumer. We aren't sending any messages to the co-process in
  #this case but if we were our output would be the input to the co-process.
  #The [in,out](put) variables are named from the perspective of the parent.
  exec {in}<&p  #store the output fdesc in $in
  inputs+=( ${in} ) #append the value in $in to the $inputs list
  exec {out}>&p #store the input fdesc in $out
  outputs+=( ${out} ) #append the value in $out to the $outputs list
done

while true; do #perpetual loop
  for counter in ${inputs[*]}; do #iterate through the list of input fdescs
    unset line_in #clear our holder variable
    read -t0.1 -u${counter} line_in #timeout after .1 seconds of no input
    if [[ -z "${line_in}" ]] ; then 
      print "${counter}: timed out" 
    else
      print "${counter}: ${line_in}"
    fi
  done 
done
