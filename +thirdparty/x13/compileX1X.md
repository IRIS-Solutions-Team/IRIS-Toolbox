# 
# Compile X13 on Mac OS X
# ========================
# 
# Update gfortran and gcc
#     brew upgrade gcc
#     brew upgrade gfortran
#
# Add this to .bashrc
#
# export LIBRARY_PATH="$LIBRARY_PATH:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"
#
# * Install XCode
#
#     sude xcode-select --install
# 
# * In XCode Preferences, enable Command Tools
# 
# * Download X1x source code archive, unzip in a temporary directory
# 
# * In makefile.xxx
#   - Set LINKER and FC both to gfortran
#   - Comment out "LDFLAGS   = -s" 
#   - Remove "-static" from "$(LINKER) -static" 
# 
# * Run "make --makefile=makefile.xxx" to build an executable
# 
# * Use "otool -L filename" to identify dependencies of the executable on other dylibs located in /usr/local/lib
# 
# * Use "install_name_tool -change old_path new_path filename" to change the path to local dylibs so that they can be redistributed within the same directory as the executable. Run the following (but double check manually for dependencies):
# 
# install_name_tool -change /usr/local/lib/libgfortran.3.dylib @executable_path/libgfortran.3.dylib x13as
# install_name_tool -change /usr/local/lib/libgcc_s.1.dylib @executable_path/libgcc_s.1.dylib x13as
# install_name_tool -change /usr/local/lib/libquadmath.0.dylib @executable_path/libquadmath.0.dylib x13as
# 
# install_name_tool -change /usr/local/lib/libgfortran.3.dylib @executable_path/libgfortran.3.dylib libgfortran.3.dylib
# install_name_tool -change /usr/local/lib/libquadmath.0.dylib @executable_path/libquadmath.0.dylib libgfortran.3.dylib
# install_name_tool -change /usr/local/lib/libgcc_s.1.dylib @executable_path/libgcc_s.1.dylib libgfortran.3.dylib
# 
# install_name_tool -change /usr/local/lib/libgcc_s.1.dylib @executable_path/libgcc_s.1.dylib libquadmath.0.dylib
# 
# 
