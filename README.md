# WEMUAV
## Introduction
Master thesis project work on Wind Estimation with Multirotor UAVs. The best way to understand and use this code is to read the master thesis present in this folder and to navigate the software documation using the "doc" commande 

## Folder structure 
- **outData** : destination of processed data
- **para** : contains parameter files, parameter generators and other empirical data
- **src** : contains source code
	- **Estimator** : contains estimation related source code
	- **Eval** : contains evaluation and results display related source code
	- **PrePro** : contains preprocessing related source code
	- **UtilsScript** : contains miscellaneous helper scripts (see file header for description)
- Master_Thesis.pdf : thesis report, usefull to understand software behaviour
- WEMUAV.prj : Matlab project (double clicking on it in Matlab sets up paths and project parameters)
- startup.m : sets up Matlab paths when during startup of Matlab (redundant with respect to Matlab project)

## Installation
- Download and install Matlab 2021a (other versions may work but were not tested)
- Downlaod and install Sensor Fusion and Tracking Toolbox (used for quaternion and euler angle implementation)
- Clone this repository
- Navigate to the cloned repository in your matlab environment
- Double click on the WEMUAV.prj matlab project file 

## Usage
- Adjust relevant parameters in the parameter generators
- Run the relevant main script (main.m, main\_PrepPro.m, main\_Estimate or main\_Eval)