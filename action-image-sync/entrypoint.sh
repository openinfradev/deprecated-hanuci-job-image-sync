#!/bin/sh -l

#TMP_DIR=/tmp/`date +%N`
#TARGET_PREFIX=tacodev
#REPOS="https://tde.sktelecom.com/stash/scm/oreotools/taco-helm.git"
TMP_DIR=$INPUT_TMP_DIR
TARGET_PREFIX=$INPUT_TARGET_PREFIX
REPOS=$INPUT_REPOS

echo $TMP_DIR : $INPUT_TMP_DIR
echo $TARGET_PREFIX : $INPUT_TARGET_PREFIX
echo $REPOS : $INPUT_REPOS

mkdir $TMP_DIR
cd $TMP_DIR
    for repo in `echo $REPOS`
    do
        git clone $repo
    done

echo "docker login as tacouser"
docker login -u tacouser -p taco1130@

for dname in `ls $TMP_DIR`
do
    echo "moving to " $TMP_DIR/$dname
    cd $TMP_DIR/$dname
    for cname in `ls`
    do
        echo ">>> now in $cname"
        for iname in `helm template $cname | grep image: | awk -F image:\  '{print $2}'`
        do
            siname=${iname//\"}
            tiname=$TARGET_PREFIX/$(echo $siname | awk -F \/ '{print $NF}')
            echo "image=$siname, targe=$tiname"
            docker pull $siname
            docker tag $siname $tiname
            docker push $tiname
        done
    done
done

rm -rf $TMP_DIR