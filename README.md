# Capacity Planning of Supercomputers: Simulating MPI Applications at Scale

This repository contains all the information regarding a research project done at the
[Laboratoire d'Informatique de Grenoble](https://www.liglab.fr/) from February 2017 to
June 2017.

## Important links

- [journal.org](journal.org): a laboratory notebook, maintained during the whole project.
It uses Emacs and [Org mode](http://orgmode.org/).
- [report.org](report/report.org): the source code of the report. It also uses Emacs and
Org mode. It automatically generates a Latex file that is then compiled into a PDF.
- [Script repository](https://github.com/Ezibenroc/m2_internship_scripts): the various
scripts used to run the experiments.
- [HPL repository](https://github.com/Ezibenroc/hpl): the optimized version of HPL.


## Dependencies

The following softwares are required.
- [Python](https://www.python.org/), version 2 (>= 2.7) *and* 3 (>= 3.4).
- [Atlas library](http://math-atlas.sourceforge.net/)

Once they are installed, run the following to set up and install everything (assuming a Debian system):
```bash
apt install smemstat

# Python dependencies
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
yes | apt install python3-dev
pip3 install lxml psutil pandas statsmodels

# Simgrid installation
git clone https://github.com/simgrid/simgrid.git
cd simgrid && mkdir build && cd build
cmake -Denable_documentation=OFF ..
make -j 4 && make install

# Optionnal, for large scale experiments
sysctl -w vm.overcommit_memory=1
sysctl -w vm.max_map_count=40000000

# Optionnal, to set up the huge pages with a hugetlbfs in /home/huge
mkdir /home/huge
mount none /home/huge -t hugetlbfs -o rw,mode=0777
echo 1 >> /proc/sys/vm/nr_hugepages
```


## Quick start

Make sure that the three repositories are cloned in the same directory.

```bash
git clone https://github.com/Ezibenroc/simulating_mpi_applications_at_scale.git
git clone https://github.com/Ezibenroc/m2_internship_scripts.git
git clone https://github.com/Ezibenroc/hpl
```

Calibrate the machine.
```bash
cd scripts
python calibrate_flops.py
FLOPS=<the returned value> # change this
cd cblas_tests
python3 runner.py 30 /tmp/cblas_coeff.csv
python3 linear_regression.py /tmp/cblas_coeff_dgemm.csv
DGEMM_COEFF=<the second returned value> # change this
python3 linear_regression.py /tmp/cblas_coeff_dtrsm.csv
DTRSM_COEFF=<the second returned value> # change this
cd ../..
```

Compile HPL with all the optimizations.
```bash
cd hpl
sed -ri "s|TOPdir\s*=.+|TOPdir="`pwd`
make startup arch=SMPI
make SMPI_OPTS="-DSMPI_OPTIMIZATION -DSMPI_DGEMM_COEFFICIENT=${DGEMM_COEFF} -DSMPI_DTRSM_COEFFICIENT=${DTRSM_COEFF}" arch=SMPI
cd ..
```

Run a series of simulations.
```bash
cd scripts
./run_measures.py --global_csv /tmp/results.csv --nb_runs 3 --size 5000,10000,15000,20000 --nb_proc 4,8,12,16 --topo "2;4,4;1,1:4;1,1" --experiment HPL --running_power ${FLOPS}
```

## Reproduce the experiments of the report

All the experiments of the report have an entry in the journal with the tag `:REPORT:`.
For each of them, the git hashes of Simgrid, the script repository and the HPL repository
are mentionned, as well as the commands used to set up and run the simulation.

To search for a particular entry, one can also search for the name of the desired PDF figure
in the report and then look for this name (which is unique) in the journal.

## Why is there only a few huge commits in this repository?

The original repository is private. It also contains copies of copyrighted papers, so it cannot be made public as is.
This is why we chosed to create this new repository by simply copying the relevant files, instead of messing with the
git history of the original repository.
