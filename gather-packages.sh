#!/bin/bash

debs="$1"

if [[ "$debs" == "" ]]; then
	echo "Usage: $0 <debs dir>"
	exit
fi

line_width="$(stty size | cut -d' ' -f2)"

function clear_line() {
    printf "\r%*c\r" "$line_width" '*'
}

for i in $debs/*.deb; do
	for arch in aarch64 all x86_64 arm; do
		dir="dists/stable/main/binary-$arch"
		mkdir -p "$dir"

		if $(echo $i | grep "_${arch}.deb" &>/dev/null) ; then
			target="$dir/$(basename $i)"
			pkg_name="$(basename $i)";
			pkg_name="${pkg_name%%_*}"

			if [[ -f "$target" ]]; then
				target_md5="$(md5sum $target | cut -d' ' -f1)"
				md5="$(md5sum $i | cut -d' ' -f1)"
				if [[ "$md5" == "$target_md5" ]]; then
					info_text="Skip"
				else
					info_text="Update"
					cp "$i" "$target"
				fi
			else
				info_text="New"
				cp "$i" "$target"
			fi
            
            clear_line
			printf "\r  %-8s\t%-8s\t%s" "$info_text" "$arch" "$pkg_name"
            if [[ "$info_text" == "New" || "$info_text" == "Update" ]]; then
                echo
            fi
			break
		fi
	done
done
echo

