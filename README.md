# GVPW

>Harnessing GaussView as a modeling and visualization tool for PWscf

[QUANTUM-ESPRESSO's PWscf](http://www.quantum-espresso.org/) is an open-source package for computional physics and chemistry. Contrary to its significance, it lacked tools for building models and visualization, forcing users to sort to various softwares, including [Material Studio](https://www.3ds.com/products-services/biovia/products/molecular-modeling-simulation/biovia-materials-studio/), [BURAI](https://nisihara.wixsite.com/burai) and [XCrySDen](http://www.xcrysden.org/), for any single task as simple as geometry optimization. On the other hand, [GaussView](http://gaussian.com/), one of the most versatile modeling and visualization tools in quantum chemistry, does not support PWscf at all by itself.

[GVPW](https://github.com/FreemanTheMaverick/GVPW) is a batch of scripts that serves to build a bridge between PWscf and GaussView. They convert input and output files between Gaussian format and PWscf format. With ```GVPW```, users will enjoy using GaussView to build complicated periodic models for PWscf calculation and watch the optimization processes of ```relax``` and ```vc-relax``` tasks. GaussView is especially useful in building "adsorbent-on-slab" model even if the adsorbent molecule is large and complex.


## Installation

+ Download ```GVPW``` from GitHub.
```
git clone https://github.com/FreemanTheMaverick/GVPW.git
```
+ Set environment variables in ```~/.bashrc```.
```
alias gjf2pwin='bash [Installation_root]/GVPW/gjf2pwin.sh'
alias pwin2gjf='bash [Installation_root]/GVPW/pwin2gjf.sh'
alias pwout2gauout='bash [Installation_root]/GVPW/pwout2gauout.sh'
```
+ Source the environment variables.
```
source ~/.bashrc
```

## Usage

### From Gaussian input to PWscf input
You need a Gaussian input ```filename.gjf``` with three lattice vectors ```Tv``` (case-sensitive) and a template file ```template.in``` in PWscf input format. The following command generates a new ```filename.in``` based on the molecular geometry and lattice constants provided by ```filename.gjf``` and other settings (cutoff, pseudopotentials, etc.) provided by ```template.in```.
```
gjf2pwin filename.gjf template.in
```
After some possible revision of the input file, ```filename.in``` is ready to be fed to PWscf.

### From PWscf input to Gaussian input
You need a PWscf input ```filename.in```. The following command generates a new ```filename.gjf``` based on the molecular geometry and lattice constants provided by ```filename.in```.
```
pwin2gjf filename.in
```
```filename.gjf``` can be viewed and modified by GaussView.

### From PWscf output to Gaussian output
You need a PWscf output ```filename.out``` of ```relax``` and ```vc-relax```, not necessarily completed normally. The following command generates an optimization output ```filename.log``` in Gaussian format.
```
pwout2gauout filename.out
```
You can watch every frame of the optimization process and its energy change in GaussView.

## Precautions
+ Set ```ibrav``` to 0 in ```filename.in``` or ```template.in```, which requests that lattice vectors be read from ```CELL_PARAMETERS``` section.
+ The molecular geometry and lattice vectors in every input file involved should be in unit of Angstrom, instead of alat or Bohr. You can set it by writing ```ATOMIC_POSITIONS angstrom``` and ```CELL_PARAMETERS angstrom``` instead of merely ```ATOMIC_POSITIONS``` and ```CELL_PARAMETERS```.
+ The energy of ```filename.log``` shown in GaussView should be in unit Rydberg, instead of Hartree.
+ ```pwout2gauout.sh``` could be slow depending on how many frames there are in the PWscf output file. Just be patient.
+ Temporary files ```init_tmp_atom```, ```init_tmp_lat```, ```tmp_atom``` and ```tmp_lat``` will be generated and removed as the scripts run. Be careful if you have files with the same names in the working directory.
+ The script ```pwout2gjf.sh``` is deprecated. It generates ```filename.gjf``` from the last frame of ```filename.out```. Its function is already included in ```pwout2gauout.sh```.

## Compatibility
```GVPW``` was tested on QUANTUM-ESPRESSO_6.8 and GaussView_6.0.16 and passed.




