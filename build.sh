find . -type f -path '*src/*' -name '*.for' -not -name 'GETOURDIR.for' -exec cat {} +> umat_general.for 
cp umat_general.for test_in_abaqus/umat_general.for
gfortran -Wextra  -pedantic -o main *.for *.f90
