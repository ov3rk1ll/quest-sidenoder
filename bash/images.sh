#!/bin/bash



ORIPATH=$PWD


addToSyncedFile () {
    DIRZ=${1::-1}
    DIRZ=${DIRZ%%\ -steam*}
    DIRZ=${DIRZ%%\ -oculus*}
    DIRZ=${DIRZ%%\ -versionCode*}
    DIRZ=${DIRZ%%\ -packageName*}
    DIRZ=${DIRZ%%\ -MP-*}
    DIRZ=${DIRZ%%\ -NA-*}
    echo "$DIRZ/**" | cut -c 3- >> "$ORIPATH/../blacklist.txt"
}


cd /tmp/mnt
COUNT=0
FAILCOUNT=0
ALLCOUNT=$(ls -l -d */ | grep "^d" | wc -l)



for d in ./*/; do

  ((COUNT++))

  if [[ ! ($d =~ .*\ -steam-.*) ]] && [[ ! ($d =~ .*\ -oculus-.*) ]] && [[ ! ($d =~ .*\ -NA-.*) ]]; then

  sleep 3

    cd "$d"

    SEARCH=${d%%v1.*}
    SEARCH=$(echo "$SEARCH"  | cut -c 3- | tr -s '_' ' ')
    SEARCH=${SEARCH%%v2.*}
    SEARCH=${SEARCH%%v3.*}
    SEARCH=${SEARCH%%v4.*}
    SEARCH=${SEARCH%%v6.*}
    SEARCH=${SEARCH%%\[*}
    SEARCH=${SEARCH%%v[0-9].*}
    SEARCH=${SEARCH%%[0-9].[0-9].*}
    SEARCH=${SEARCH%%v[0-9][0-9]*}
    SEARCH=${SEARCH%%v[0-9][0-9].*}
    SEARCH=${SEARCH%%v1*}

    SEARCH=${SEARCH%% - Untethered*}
    SEARCH=${SEARCH%%v1*}




    echo "Generating $SEARCH for $d"


    link=$(curl  -G --silent --data-urlencode "vrsupport=1" --data-urlencode "term=$SEARCH" -L "https://store.steampowered.com/search/" | sed -En '/search_capsule"><img/s/.*src="([^"]*)".*/\1/p' | head -n 1)

    link=${link%%\?*}

    echo "$link"

    if [[ "$link" != *".jpg" ]] || [[ "$link" == *"/bundles/"* ]] || [[ "$link" == "" ]] || [[ "$link" != *"jpg" ]] ;then
      echo "NOT A REAL IMAGE -> $link"
      ((FAILCOUNT++))
      cd ..

      mv "${d::-1}" "${d::-1} -NA-"


      continue
    fi







    if [[ "$link" != "" ]] && [[ "$link" == *"jpg" ]];then

      ID=${link%%/capsule_*}
      ID=${ID##*apps/}
      echo "ID FOUND: $ID"
      DIRZ=${d::-1}
      echo "d: $DIRZ"
      cd ../


      mv "$DIRZ" "${d::-1} -steam-$ID"

    else
      cd ../
    fi



  fi

  addToSyncedFile "$d"
done

sort -u "$ORIPATH/../blacklist.txt" > "$ORIPATH/../blacklistUNIQUE.txt"
mv "$ORIPATH/../blacklistUNIQUE.txt" "$ORIPATH/../blacklist.txt"


echo "$COUNT items looped"
echo "$FAILCOUNT items failed"
#echo "$(cat $ORIPATH/../quotesynced.txt | wc -l) from quotesynced.txt"
paplay /usr/share/sounds/ubuntu/ringtones/Bliss.ogg
sleep 99


