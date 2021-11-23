# GVPW

>Harnessing GaussView as a modeling and visualization tool for PWscf

[QUANTUM-ESPRESSO's PWscf](http://www.quantum-espresso.org/) is an open-source package for computional physics and chemistry. In contrary to its significance, it lacked tools for building models and visualization, forcing users to sort to various softwares, including [Material Studio](https://www.3ds.com/products-services/biovia/products/molecular-modeling-simulation/biovia-materials-studio/), [BURAI](https://nisihara.wixsite.com/burai) and [XCrySDen](http://www.xcrysden.org/), for any single task as simple as geometry optimization. On the other hand, [GaussView](http://gaussian.com/), one of the most versatile modeling and visualization tool in quantum chemistry, does not support PWscf at all.

[GVPW](https://github.com/FreemanTheMaverick/GVPW) is a batch of scripts that serves to build a bridge between PWscf and GaussView. They convert input and output files between Gaussian format and PWscf format. With GVPW, users will enjoy using GaussView to build complicated periodic models for PWscf calculation and watch the optimization processes of 'relax' and 'vc-relax' tasks.

## Users' Guide

How to get ```GVPW``` to work.

### Installation

Download ```GVPW``` from ```GitHub```.
```
git clone https://github.com/FreemanTheMaverick/GVPW.git
```
Set environment variables.
```
alias gjf2pwin='bash [Installation_root]/GVPW/gjf2pwin.sh'
alias pwin2gjf='bash [Installation_root]/GVPW/pwin2gjf.sh'
alias pwout2gauout='bash [Installation_root]/GVPW/pwout2gauout.sh'
```

### Usage

#### From ```Gaussian``` input to ```PWscf``` input





