#!/bin/sh

# https://github.com/interiordefecator/photosbd

GREEN='\033[0;32m'
BLUE='\033[1;34m'
NC='\033[0m'

SORT_MODE="month"
moved_count=0

# parse opts (specificity of sorting, target)
while getopts "ymd" opt; do
    case "$opt" in
        y) SORT_MODE="year" ;;
        m) SORT_MODE="month" ;;
        d) SORT_MODE="day" ;;
        *)
            echo "Usage: $0 [-y|-m|-d] [target_directory]"
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))
TARGET_DIR="$1"

# confirm current dir if no target specified
if [ -z "$TARGET_DIR" ]; then
    echo "No target directory provided."
    printf "Would you like to use the current directory (%s)? [y/N]: " "$PWD"
    read -r confirm
    case "$confirm" in
        [Yy]* ) TARGET_DIR="$PWD" ;;
        * ) echo "Aborting."; exit 1 ;;
    esac
fi

# check if target exists, if not then exit
if [ ! -d "$TARGET_DIR" ]; then
    echo "Directory '$TARGET_DIR' does not exist."
    printf "Would you like to create it? [y/N]: "
    read -r reply
    case "$reply" in
        [Yy]* )
            mkdir -p "$TARGET_DIR" || {
                echo "Failed to create directory."
                exit 2
            }
            ;;
        * )
            echo "Aborting."
            exit 2
            ;;
    esac
fi

# main loop (recursive)
while IFS= read -r fil; do
    datetime=$(identify -verbose "$fil" | grep DateTimeOri | awk '{print $2}')
    
    if [ -z "$datetime" ]; then
        echo "Warning: No DateTimeOriginal found for '$fil'"
        continue
    fi

    year=$(echo "$datetime" | cut -d: -f1)
    month=$(echo "$datetime" | cut -d: -f2)
    day=$(echo "$datetime" | cut -d: -f3)

    case "$SORT_MODE" in
        year)
            datepath="$TARGET_DIR/$year"
            ;;
        month)
            datepath="$TARGET_DIR/$year/$month"
            ;;
        day)
            datepath="$TARGET_DIR/$year/$month/$day"
            ;;
    esac

    mkdir -p "$datepath"
    if mv "$fil" "$datepath/"; then
        moved_count=$((moved_count + 1))
        printf "\r${BLUE}Moved: %d${NC}  ${GREEN}%s${NC}        " "$moved_count" "$fil"
    fi
done < <(find "$TARGET_DIR" -type f -iname '*.jpg')

echo ""
find "$TARGET_DIR" -type d -empty -delete
echo -e "${BLUE}Finished. Total images moved: $moved_count${NC}"
