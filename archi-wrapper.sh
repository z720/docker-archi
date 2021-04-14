#! /bin/bash

echo "Working dir: `pwd`"
echo "Starting Archi CLI with $@"

# Parse Arguments 
PARAMS=""
ARGS=""
PLUGINDIR=""

while (( "$#" )); do
  case "$1" in
    -h|--help)
      # Show help
			echo "Available options"
			echo " - -m|--model path to model to open, considered a repository already checked out"
			echo " - --script : path to script to be passed to -script.runScript"
			echo " - --html : path to html documentation do be created"
			exit 0
      ;;
    -m|--model)
      echo "Try to load model $2"
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        ARGS="$ARGS --modelrepository.loadModel $2"
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --pluginDir)
      echo "Try to load plugins in $2"
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PLUGINDIR="$2"
        shift 2
        # Install plugins first
        ls -l $PLUGINDIR/*.archiplugin
        for z in "$PLUGINDIR/*.archiplugin"; do 
          echo "Try to activate plugin $z"; 
          unzip -o "$z" -d /root/.archi4/dropins
        done
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
		--script)
      echo "Try to execute script $2"
      if [ -z "$PLUGINDIR" ]; then echo "WARNING: --pluginDir not provided: Script might not execute at all..."; fi
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        ARGS="$ARGS --script.runScript $2"
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
		--html)
      echo "Try to generate HTML reports in $2"
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        ARGS="$ARGS --html.createReport $2"
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    # -*|--*=) # unsupported flags
    #   echo "Error: Unsupported flag $1 ($@)" >&2
    #   exit 1
    #   ;;
    # *) # preserve positional arguments
    #   PARAMS="$PARAMS $1"
    #   shift
    #   ;;
  esac
done
# set positional arguments in their proper place
# eval set -- "$PARAMS"

# Run Archi in the command line
/opt/Archi/Archi -application com.archimatetool.commandline.app \
	-consoleLog -nosplash $ARGS