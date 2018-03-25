
echo "package: making folder"
zipname=`ls *.l -1 | sed 's/\(.*\)\..*/\1/'`
mkdir "$zipname"

echo "package: copying files"

# copy flex/bison files
cp $zipname.* "$zipname"

# copy C++ files
# fail silently because these may not exist and that's ok
cp *.h "$zipname" 2>>/dev/null || :
cp *.cpp "$zipname" 2>>/dev/null || :
cp *.hpp "$zipname" 2>>/dev/null || :

echo "package: zipping"
zip -r "$zipname.zip" "$zipname"

echo "package: cleanup"
rm -r "$zipname"
