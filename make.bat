

rem  Minimal makefile for Sphinx documentation
rem 

rem  You can set these variables from the command line.
set SPHINXOPTS =
set SPHINXBUILD=sphinx-build
set SOURCEDIR= .
set BUILDDIR= _build

rem  Catch-all target: route all unknown targets to Sphinx using the new
rem  "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%SPHINXBUILD% -M html "%SOURCEDIR%" "%BUILDDIR%" %SPHINXOPTS%