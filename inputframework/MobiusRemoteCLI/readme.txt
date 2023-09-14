
#----------------------------------------------------------------
# Create MobiusRemoteCLI-ifw.tar
# IMPORTAN NOTES: 
#   - MobiusRemoteCLI.sh, acreate-cli.jar, and BOOT-INF/" are in the original package
#   - MobiusRemoteCLIifw.sh only adds the line 3, the rest is the same as MobiusRemoteCLI.sh 
#          PATH=/opt/asg/java/bin:$PATH
#
#----------------------------------------------------------------
tar -cvf MobiusRemoteCLIifw.tar MobiusRemoteCLI.sh MobiusRemoteCLIifw.sh  acreate-cli.jar BOOT-INF/

#----------------------------------------------------------------
# Copy MobiusRemoteCLIifw.tar and setup.sh
# IMPORTAN NOTES: 
#   . setup creates the missing directories, and chows to mobius it also creates acreate.sh
#----------------------------------------------------------------
kubectl -n ifw cp ./MobiusRemoteCLIifw.tar inputframework-dbcb89d64-lnklh:/inbox/MobiusRemoteCLIifw.tar --no-preserve=true
kubectl -n ifw cp ./setup.sh inputframework-dbcb89d64-lnklh:/inbox/setup.sh --no-preserve=true


#----------------------------------------------------------------
# Extract MobiusRemoteCLI tar files, chnage owner to mobius, grant execute for .sh files
#----------------------------------------------------------------
kubectl -n ifw exec -it inputframework-dbcb89d64-lnklh -- bash
    cd /inbox
    . ./setup.sh



