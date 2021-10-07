#!/bin/bash
# bash wrapper for shiny app
set -e
set -o pipefail

show_help(){
cat << EOF
usage: $(echo $0) [-d <app_dir>] [-p <port>] [-t <type>] [-H <host>]
	-d app_dir: where is shiny app.
	-p port: which port that shiny app run on.
	-t app_type: which app type that you want to launch.
	-H host: which host that shiny app run on.
EOF
}

while getopts ":hd:p:H:" arg
do
	case "$arg" in
		"d")
			app_dir="$OPTARG"
			;;
		"p")
			port="$OPTARG"
			;;
        "t")
            app_type="$OPTARG"
            ;;
		"H")
			host="$OPTARG"
			;;
		"?")
			echo "Unkown option: $OPTARG"
			exit 1
			;;
		":")
			echo "No argument value for option $OPTARG"
			;;
		h)
			show_help
			exit 0
			;;
		*)
			echo "Unknown error while processing options"
			show_help
			exit 1
			;;
	esac
done

if [ -z "$app_dir" ] || [ -z "$port" ];then
    echo "You must specify the -d and -p arguments."
    exit 1
fi

if [ -z "$app_type" ];then
    app_type='shiny'
fi

if [ -z "$host" ];then
	host='127.0.0.1'
fi

if [ "$app_type" == 'shiny' ];then
    # Change working directory
    cd ${app_dir}
    echo "Port: $port"
    echo "The shiny app (${app_dir}) is running..."
    R -e "shiny::runApp(appDir='./', port=${port}, host='${host}')"
fi