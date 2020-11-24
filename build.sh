find . -type f -path '*src/*' -name '*.for' -exec cat {} +> umat_general.for 
gfortran -Wextra  -pedantic -o main *.for *.f90
find . -type f -path '*src/*' -name '*.for' -not -name 'GETOUTDIR.for' -exec cat {} +> test_in_abaqus/umat_general.for 
