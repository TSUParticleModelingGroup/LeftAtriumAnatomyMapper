# Interative Left Atrium Tissue Mapper


<a id="selected-pics"></a>  
<img src="ReadMeImages/Model_Colored.png" width=30% height=30% class='center'></img>

<a id="project-aims"></a>  

The purpose of this code is to read raw node and muscle files, allow the user to identify left atrial tissue types for use in the Left Atrial Simulator, and convert the raw files into a binary format that can be read by the simulator.

The program reads a raw left atrium model consisting of a raw node file and a raw muscle file.

---

## Raw Node File Format

The raw node file has the following format:

```text
int: Number of nodes

int: NodeID  float: Node position x  float: Node position y  float: Node position z
int: NodeID  float: Node position x  float: Node position y  float: Node position z
...
int: NodeID  float: Node position x  float: Node position y  float: Node position z
```

---

## Raw Muscle File Format

The raw muscle file has the following format:

```text
int: Number of muscles

int: MuscleID  int: First node connection  int: Second node connection
int: MuscleID  int: First node connection  int: Second node connection
...
int: MuscleID  int: First node connection  int: Second node connection
```

---

## Loading the Model

The user must specify the name of the raw file in the startup file.

The node structures are loaded along with the muscles connected to them. The natural lengths of the muscles are calculated and stored in their corresponding muscle structures.

The `PulsePointNode` is initialized as node `0`. Its tissue type, along with the tissue types of its attached muscles, is set to **Bachmann's Bundle**. All remaining nodes and muscles are initialized as standard left atrial (LA) tissue.

These assignments can be changed later through the user interface, but they are initialized in this manner so that the user can immediately generate a model consisting entirely of standard LA tissue with a simple `PulsePointNode`.

---

## Assigning Tissue Types

The user can select the `PulsePointNode` and choose tissue types from the drop-down menu on the right side of the interface.

A sphere attached to the mouse cursor is used to assign tissue types to nodes:

* **Left Click** – Assign the selected tissue type to nodes and attached muscles.
* **Right Click** – Reset nodes and muscles to standard LA tissue.

The currently available tissue types are:

* Bachmann's Bundle
* Pulmonary Vein
* Back Wall
* Mitral Valve
* Left Atrial Appendage
* Scar Tissue
* Extra Tissue

---

## Muscle Tissue Assignment Rules

Muscles are assigned tissue types based on the node types they connect.

If a muscle connects two nodes with different tissue types, the muscle is assigned the tissue type that appears earlier in the following priority list:

1. Bachmann's Bundle
2. Pulmonary Vein
3. Back Wall
4. Mitral Valve
5. Left Atrial Appendage
6. Scar Tissue
7. Extra Tissue

---

## PulsePointNode Behavior

The `PulsePointNode` is always assigned the **Bachmann's Bundle** tissue type.

If the `PulsePointNode` is changed during the annotation process:

1. The previous `PulsePointNode` is reset to standard LA tissue.
2. The newly selected node is assigned the Bachmann's Bundle tissue type.
3. All affected muscles are updated accordingly.

---

## Saving the Binary File

Once all desired tissue types have been assigned, click **Save Binary**.

The node and muscle structures are saved to a timestamped binary file to prevent previously saved files from being overwritten.

---

## Editing Existing Binary Files

The user may modify as much or as little of the model as desired.

To make additional changes to a previously modified model:

1. Specify the saved binary file in the startup file.
2. Run the program again.
3. Make any desired modifications.
4. Click **Save Binary**.

All previous modifications will be preserved. A new timestamped binary file will be created when the model is saved, ensuring that the original file is not overwritten.





<a id="installation"></a>
## Installation
### Hardware Requirements:
- This simulation requires a CUDA-enabled GPU from Nvidia. Click <a href="https://developer.nvidia.com/cuda-gpus">here </a> for a list of GPUs.

| *Note: These are guidelines, not rules | CPU                            | GPU                   | RAM       |
|----------------------------------------|--------------------------------|-----------------------|-----------|
| Minimum:                               | AMD/Intel Six-Core Processor   | Any CUDA-Enabled GPU  | 16GB DDR4 |
| Recommended:                           | AMD/Intel Eight-Core Processor | RTX 3090/Quadro A6000 | 32GB DDR5 |

### Software Requirements:

#### Disclosure: This simulation only works on Linux-based distros currently. All development and testing was done in Ubuntu 20.04/22.04

#### This Repository contains the following:
- [Nsight Visual Studio Code Edition](https://developer.nvidia.com/nsight-visual-studio-code-edition)
- [CUDA](https://developer.nvidia.com/cuda-downloads)
   - OpenGL
        - [Nvidia Driver For OpenGL](https://developer.nvidia.com/opengl-driver)
        - [OpenGL Index](https://www.khronos.org/registry/OpenGL/index_gl.php)
#### Linux (Ubuntu/Debian)
  Install Nvidia CUDA Toolkit:

	sudo apt update
    sudo apt install nvidia-cuda-toolkit

 If your screens are not getting recognized, you may try this and reboot:

	sudo apt update
	sudo apt install --reinstall nvidia-drivers-595-open
	sudo reboot

  Install Mesa Utils:

	sudo apt update
    sudo apt install mesa-utils

  Install gcc and nvcc:

    sudo apt update
	sudo apt install build-essential

  Install GLFW:

    sudo apt update
	sudo apt install libglfw3-dev libglu1-mesa-dev freeglut3-dev mesa-common-dev
	
  Install X11-related libraries:

    sudo apt update
	sudo apt install libxinerama-dev libxcursor-dev libxi-dev
	
  Install gedit:
  
    sudo apt update
	sudo apt install gedit

  Install ffmpeg:
  
    sudo apt update
	sudo apt install ffmpeg


<a id="building-and-running"></a>    
## Building and Running

### Building (Note: this must be done after every code change)

  Navigate to the cloned folder and run the following command to build and compile the simulation:

    ./compile

  If it says that you do not have permissions, run the following command and try again.

  	chmod +x compile

### Running
  After compiling, run the simulation:

    ./run

<a id="simulation-setup-file"></a>    
## Simulation Setup Files 
	There are three simulation setup files. 
	These files can be adjusted by the user before running a simulation to set up the basic framework of the run.
	All units used in the simulation are as follows:
   	Length is in millimeters (mm)
   	Time is in milliseconds (ms)
   	Mass is in grams (g)
   
### BasicSimulationSetup
   	This file is read at startup and tells the program to either resume the simulation from a previous run or create a new run from the 
	frameworks in the nodes and muscles files. It also reads in some basic visualization parameters.
	
### IntermediateSimulationSetup
   	This file is read at startup and sets base simulation settings, such as beat rate and node and muscle characteristics. 
	It also reads in several visualization parameters.  

### AdvancedSimulationSetup
   	This file is read at startup and sets the basic physics of the simulation.

<a id="simulation-runtime-controls"></a>
## Simulation Runtime Controls

  Our model includes a Graphical User Interface (GUI) to allow the user to dynamically adjust various attributes for both the simulation and various characteristics of the left atrium.

  <img src="ReadMeImages/GUI.png" width=30% height=30%>

### Simulation Controls
*Primary controls for managing the simulation execution and visual output.*

| Control | Description |
| :--- | :--- |
| **Contraction Toggle** | Enables/disables visual contraction of heart tissue |
| **Draw Front Half Only** | Renders only the closest half of the model for clarity/performance |
| **Show Nodes** | Toggle to draw front half/all/no nodes |
| **Record Video** | Starts/stops recording simulation video |
| **Screenshot** | Captures still image of current view |
| **Simulation Speed** | Determines the amount of calculations in between render calls |

### Mouse Functions
*Interactive modes for mouse actions on 3D heart surface.*

| Mode | Description |
| :--- | :--- |
| **Mouse Off** | Turns all mouse functions off |
| **Ablate Mode** | Block (ablate) the signal from traveling through selected nodes |
| **Ectopic Beat** | Sets up a recurrent timed pulse (beat) from the selected node |
| **Ectopic Trigger** | Initiates a single pulse from the selected node |
| **Adjust Area** | Select/modify muscle characteristics for a group of muscles |
| **Adjust Line** | Select/modify muscle characteristics for a single muscle |
| **Identify Node** | Identify the number that corresponds to a specific node |

### Heartbeat Controls
*Panel for management of cardiac rhythms*

| Control | Description |
| :--- | :--- |
| **Beat Period (ms)** | Sets baseline interval between heartbeats |
| **Ectopic Beats** | View/Adjust current ectopic beats |

### Utilities
*Tools for saving/loading simulation states.*

| Utility | Description |
| :--- | :--- |
| **Save Settings** | Exports simulation parameters to a file for later use |
| **Find Nodes** | Finds the ID of the top-most and front-most node |
| **Save State** | Saves complete simulation state for short-term use |
| **Load State** | Restores simulation from saved state |

<a id="changelog"></a>
## Changelog

Refer to the changelog for details.

<a id="license"></a>
## License
  - This code is protected by the MIT License and is free to use for personal and academic use.

<a id="contributing-authors"></a>
## Contributing Authors
  - Leah Rogers
  - Mason Bane
  - Kyla Moore
  - Gavin McIntosh
  - Avery Campbell
  - Melanie Little
  - Derek Hopkins
  - Brandon Wyatt
  - Madhur Wyatt
  - Charles Puelz (CoPI)
  - Bryant Wyatt (PI)

<a id="funding-sources"></a>  
## Funding Sources
This research was supported by the NVIDIA cooperation’s Applied Research Accelerator
Program. Student support was provided by Tarleton State University’s Presidential
Excellence in Research Scholars and the Bill and Winnie Wyatt Foundation.

<a id="acknowledgements"></a>
## Acknowledgements
We would like to thank Tarleton State University’s Mathematics Department for use of
their High-Performance Computing lab for the duration of this project.

<a id="references"></a>
## References
  
	[1] World Health Organization. (12/9/2020). The top 10 causes of death. World Health Organization. https://www.who.int/news-room/fact-sheets/detail/the top-10-causes-of-death
	[2] Virani SS, Alonso A, Aparicio HJ, Benjamin EJ, Bittencourt MS, Callaway CW, Carson AP, Chamberlain AM, Cheng S, Delling FN, Elkind MSV, Evenson KR, Ferguson JF, Gupta DK, Khan SS, Kissela BM, Knutson KL, Lee CD, Lewis TT, Liu J, Loop MS, Lutsey PL, Ma J, Mackey J, Martin SS, Matchar DB, Mussolino ME, Navaneethan SD, Perak AM, Roth GA, Samad Z, Satou GM, Schroeder EB, Shah SH, Shay CM, Stokes A, VanWagner LB, Wang NY, Tsao CW; American Heart Association Council on Epidemiology and Prevention Statistics Committee and Stroke Statistics Subcommittee. Heart Disease and Stroke Statistics-2021 Update: A Report From the American Heart Association. Circulation. 2021 Feb 23;143(8):e254-e743. doi: 10.1161/CIR.0000000000000950. Epub 2021 Jan 27. PMID: 33501848.
	[3] Brundel BJJM, Ai X, Hills MT, Kuipers MF, Lip GYH, de Groot NMS. Atrial fibrillation. Nature Reviews Disease Primers. 2022;8(1):21–21.
	[4] Staerk L, Sherer JA, Ko D, Benjamin EJ, Helm RH. Atrial Fibrillation. Circulation Research. 2017;120(9):1501–1517.
	[5] Pellman J, Sheikh F. Atrial fibrillation: mechanisms, therapeutics, and future directions. Comprehensive Physiology. 2015.
	[6] Beigel R, Wunderlich NC, Ho SY, Arsanjani R, Siegel RJ. The left atrial appendage: anatomy, function, and noninvasive evaluation. JACC Cardiovasc Imaging. 2014 Dec;7(12):1251-65. doi: 10.1016/j.jcmg.2014.08.009. PMID: 25496544.
	[7] Singleton MJ, Imtiaz-Ahmad M, Kamel H, O'Neal WT, Judd SE, Howard VJ, Howard G, Soliman EZ, Bhave PD. Association of Atrial Fibrillation Without Cardiovascular Comorbidities and Stroke Risk: From the REGARDS Study. J Am Heart Assoc. 2020 Jun 16;9(12):e016380. doi: 10.1161/JAHA.120.016380. Epub 2020 Jun 4. PMID: 32495723; PMCID: PMC7429041.
	[8] Antzelevitch C, Burashnikov A. Overview of Basic Mechanisms of Cardiac Arrhythmia. 2011.
	[9] Long MT, Ko D, Arnold LM, Trinquart L, Sherer JA, Keppel SS, Benjamin EJ, Helm RH. Gastrointestinal and liver diseases and atrial fibrillation: a review of the literature. Therap Adv Gastroenterol. 2019 Apr 2;12:1756284819832237. doi: 10.1177/1756284819832237. PMID: 30984290; PMCID: PMC6448121.
	[10] Carlo P, Giuseppe A, Simone S, Filippo G, Gabriele V, Simone G, Gabriele P, Patrizio M, Nicoleta S, Isabelle G, Andreina S, Laura L, Nicola P, Andrea R, Francesco M, et al. A Randomized Trial of Circumferential Pulmonary Vein Ablation Versus Antiarrhythmic Drug Therapy in Paroxysmal Atrial Fibrillation. Journal of the American College of Cardiology. 2006;48(11):2340–2347.
	[11] Charitakis E, Metelli S, Karlsson LO, Antoniadis AP, Rizas KD, Liuba I, Almroth H, Hassel Jönsson A, Schwieler J, Tsartsalis D, Sideris S, Dragioti E, Fragakis N, Chaimani A. Comparing efficacy and safety in catheter ablation strategies for atrial fibrillation: a network meta-analysis. BMC Medicine. 2022;20(1):193–193.
	[12] Cheng E, Liu C, Yeo I, Markowitz S, George T, Ip J, Kim LK, Lerman BB. Risk of Mortality Following Catheter Ablation of Atrial Fibrillation. Journal of the American College of Cardiology. 2019;74(18):2254–2264.
	[13] Mujović N, Marinković M, Lenarczyk R, Tilz R, Potpara TS. Catheter Ablation of Atrial Fibrillation: An Overview for Clinicians. Advances in Therapy. 2017;34(8):1897–1917.
	[14] Cappato R, Calkins H, Chen S-A, Davies W, Iesaka Y, Kalman J, Kim Y-H, Klein G, Natale A, Packer D, Skanes A, Ambrogi F, Biganzoli E. Updated Worldwide Survey on the Methods, Efficacy, and Safety of Catheter Ablation for Human Atrial Fibrillation. Circulation: Arrhythmia and Electrophysiology. 2010;3(1):32–38.
	[15] Ganesan AN, Shipp NJ, Brooks AG, Kuklik P, Lau DH, Lim HS, Sullivan T, Roberts-Thomson KC, Sanders P. Long-term Outcomes of Catheter Ablation of Atrial Fibrillation: A Systematic Review and Meta-analysis. Journal of the American Heart Association. 2013;2(2).
	[16] Quah JX, Dharmaprani D, Lahiri A, Tiver K, Ganesan AN. Reconceptualising Atrial Fibrillation Using Renewal Theory: A Novel Approach to the Assessment of Atrial Fibrillation Dynamics. Arrhythmia & Electrophysiology Review 2021;10(2):77–84. 2021.
	[17] Markides V, Schilling RJ. Atrial fibrillation: classification, pathophysiology, mechanisms and drug treatment. Heart. 2003 Aug;89(8):939-43. doi: 10.1136/heart.89.8.939. PMID: 12860883; PMCID: PMC1767799.
	[18] Wyndham CRC. Atrial Fibrillation: The Most Common Arrhythmia. Texas Heart Institute Journal. 2000;27(3):257–257.
	[19] Cheniti G, Vlachos K, Pambrun T, Hooks D, Frontera A, Takigawa M, Bourier F, Kitamura T, Lam A, Martin C, Dumas-Pommier C, Puyo S, Pillois X, Duchateau J, Klotz N, et al. Atrial Fibrillation Mechanisms and Implications for Catheter Ablation. Frontiers in Physiology. 2018;9.
	[20] Gussak G, Pfenniger A, Wren L, Gilani M, Zhang W, Yoo S, Johnson DA, Burrell A, Benefield B, Knight G, Knight BP, Passman R, Goldberger JJ, Aistrup G, Wasserstrom JA, Shiferaw Y, Arora R. Region-specific parasympathetic nerve remodeling in the left atrium contributes to creation of a vulnerable substrate for atrial fibrillation. JCI Insight. 2019 Oct 17;4(20):e130532. doi: 10.1172/jci.insight.130532. PMID: 31503549; PMCID: PMC6824299.

The Particle Modeling Group reserves the right to change this policy at any time.
