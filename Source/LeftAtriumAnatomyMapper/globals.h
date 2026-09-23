/*
 This file contains all include files, the #defines, structures and globals used in the simulation.
 All the functions are prototyped in this file as well.
*/

// External include files
#include <iostream>
#include <fstream>
#include <sstream>
#include <string.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/stat.h>
#include <signal.h>
#include <unistd.h>
#include <stdbool.h>
#include <vector> //needed for VBOs

// Needed to make 
//#include <cuda_runtime.h>

// OpenGL headers - GLAD must come BEFORE GLFW
#include "../include/glad/glad.h"
#include <GL/glu.h>
#include <GLFW/glfw3.h>

// ImGui headers - use quotes for local includes, not angle brackets
#include "../third_party/imgui/imgui.h"
#include "../third_party/imgui/imgui_impl_glfw.h"
#include "../third_party/imgui/imgui_impl_opengl3.h"


// TODO absolutely need to remove this, it can mess up a lot of code
using namespace std;

// Cuda defines
#define FLOATMAX 3.4028235e+38f
#define INTMAX 2147483647

// Defines for terminal print
#define BOLD_ON  "\e[1m"
#define BOLD_OFF   "\e[m"

// Math defines.
#define PI 3.141592654
#define ASUMEZERO 0.0000001f

// Structure defines. 
// This sets how many muscle can be connected to a node.
#define MUSCLES_PER_NODE 20

// ************************************************* Structures **********************************************************
// Everything a node holds.
typedef struct 
{
	float4 position;
	float4 color;
	int type;
	int muscle[MUSCLES_PER_NODE];
} nodeAttributesStructure;

// Everything a muscle holds.
typedef struct 
{
	int type;
	int nodeA;
	int nodeB;  
	float naturalLength;
	float4 color;
} muscleAttributesStructure; 

// This structure will contain all the switches that control the actions in the code.
typedef struct 
{
	int mouseMode; // can be used to set the mode of the mouse, like ablate mode, ectopic beat mode, adjust muscle area mode, or adjust muscle line mode.
	int DrawNodesFlag; 
	int DrawFrontHalfFlag;
	bool isInMouseFunctionMode; // This is true if the user is in any of the mouse function modes, like ablate mode, ectopic beat mode, adjust muscle area mode, or adjust muscle line mode.
	bool guiCollapsed; // for hotkey to collapse GUI
} simulationSwitchesStructure;

// ******************************************** Globals ******************************************

// Node types: Assigns a number for the different types of tissue. They are set here.
const int TypeStandardLA = 0;
const int TypeBachmannBundle = 1;
const int TypeAppendage = 2;
const int TypeScarTissue = 3;
const int TypePulmonaryVeins = 4;
const int TypeMitralValve = 5;
const int TypeBackWall = 6;
const int TypeExtraTissue = 7;
// This is not a tissue type it is where we initiate the beat.
// The tissue type of the pulseNode is BacchannBundle 
// This node just has the extra task of oracstrating the beat.
// We set it to be 100 so we can add addition tissue types in the future as needed.
const int TypePulseNode = 100;

// Color types: Assigns a color to each of the tissue type. They are set here.
const float4 ColorStandardLA = {1.0f, 0.0f, 0.0f, 0.0f}; // Red for standard nodes (to reduce contrast)
const float4 ColorBachmannsBundle = {0.2f, 0.2f, 1.0f, 0.0f}; // Blue for Bachmann's Bundle nodes and muscles by default.
const float4 ColorAppendage = {1.0f, 0.8f, 0.3f, 0.0f}; // Orange for left atrial appendage nodes and muscles by default.
const float4 ColorScarTissue = {0.6f, 0.6f, 0.6f, 0.0f}; // Gray for scar tissue nodes and muscles by default.
const float4 ColorPulmonaryVeins = {1.0f, 0.4f, 0.7f, 0.0f}; // Pink for pulmonary veins nodes and muscles by default.
const float4 ColorMitralValve = {0.5f, 0.0f, 0.5f, 0.0f}; // Purple for mitral valve nodes and muscles by default.
const float4 ColorBackWall = {0.0f, 1.0f, 0.0f, 0.0f}; // Green for back wall nodes and muscles by default.
const float4 ColorExtraTissue = {0.6f, 0.6f, 0.6f, 0.0f}; // Gray for extra tissue nodes and muscles by default.

// How many nodes and muscle the simulation contains.
// They are read in form the Raw or Bin files. 
// Node and Muscle structure memory is allocated from these numbers.
// They are set to -1 here to flag for errors if something goes wrong while reading them in.
int NumberOfNodes = -1;
int NumberOfMuscles = -1;

// These hold all the nodes and muscle structures.
// They are generated for raw files or read in from bin files.
nodeAttributesStructure *Node;
muscleAttributesStructure *Muscle;

// This will hold all the simulation switches.
// It is initialized in setup() function.
simulationSwitchesStructure Simulation;

// To use VBOs for sphere rendering.
// Vertex Buffer Object and Index Buffer Object for sphere rendering, 
// Vertex is the sphere's vertices and Index is the order in which to draw them.
// They are initialized in the function glGenBuffers(int, &GLuint);
GLuint SphereVBO, SphereIBO; 
// Number of vertices and indices in the sphere geometry
// They are initialized in the function createSphereVBO(float, int, int).
GLuint NumSphereVertices, NumSphereIndices;

// This is the node where the beat initiates from. 
// It is read in from a binary file or set to 0 in setup if a raw file is read in.
// It is set to -1 here for error checking.
int PulsePointNode = -1;

// Holds the name of the medical view you are in for displaying in the terminal print.
// It is initialized here.
char ViewName[256] = "no view set"; 

// Status line shown in GUI after saving binary files.
// It is initialized to show nothing.
char SubGUIMessage[512] = "";

// These are all the globals that are read in from the ConfigSetup.
// They are initialize here to bogus value for error checking.
char NodesMusclesFileName[256] = "";
float LineWidth = -1.0;
float NodeRadiusAdjustment = -1.0;
float NodePointSize = -1.0;
float4 BackGroundColor = {1.0f, 1.0f, 1.0f, 0.0f};

// This holds the average radius of the object which is use to scale the size of everything.
// It is calculated in findAverageRadiusOfObject().
// It is initialized to -1.0 for error checking.
double RadiusOfLeftAtrium = -1.0;

// This holds the selection radius around the mouse for selecting nodes. It is initialized in setup().
// It is initialized to -1.0 here for error checking.
double MouseSelectionRadius = -1.0;

// Variable that holds mouse locations to be translated into center of the selection sphere.
// They are initialized in setup().
double MouseX, MouseY, MouseZ;

// Variables that are used to adjust the scroll speed of the mouse.
// Pressing the center mouase button will toggle you between a fast and slow scroll speed.
// They are initialized here and in setup().
int ScrollSpeedToggle = 1;
double ScrollSpeedFast = 1.0;
double ScrollSpeedSlow = 0.1;
double ScrollSpeed;

// These keep track of where the view is as you translate and rotate the object.
// They are initialized here.
float4 CenterOfSimulation = {0.0f, 0.0f, 0.0f, 0.0f};
float4 AngleOfSimulation  = {0.0f, 1.0f, 0.0f, 0.0f};

// Window globals 
// They are all initialized in setup() because some of them depend of the RadiusOfLeftAtrium
// which is initialize in setup.
GLFWwindow* Window; // Window pointer
// Window size
int XWindowSize;
int YWindowSize; 
// Front and back of clip planes
double Near; 
double Far;
// Where your eye is
double EyeX; 
double EyeY;
double EyeZ;
// Where you are looking
double CenterX; 
double CenterY;
double CenterZ;
// What up means to the viewer
double UpX; 
double UpY;
double UpZ;

// I was having a problem where the GUI was freeing memory before I
// freed it at program shutdown, causing a core dump when the program
// terminated. I added this to the GUI loop, and the error went away.
// I'm not sure why the standard GUI technique didn't work, but this
// fixed the issue. I may remove it in the future and spend some time
// figuring out what is actually happening. For now, however, this
// solution is working.
// I initialize it here. 
int Run = 1;

//******************************************** Function Prototypes ***********************************************
// File input Functions
void readLAMAppingSetupParameters();  //Done
void readNodesFromRawFile(); //Done 
void readMusclesFromRawFile(); //Done
void readNodesAndMusclesFromBinaryFile(); //Done

// File Output Functions
void saveBinary(); //done

// Setup Functions
void setup();
void checkNodes(); //done
void linkRawNodesToMuscles(); //done
double findAverageRadiusOfObject(); //done
void setMuscleNaturalLength(); //done

// User Action Functions
//void setReferencePoints();//done
void assignNodes(float3, int); // done

// Image Functions
void createImage();
void renderSphereVBO();
void renderSphere(float, int, int);
void createSphereVBO(float, int, int);
void screenShot();

// Callback Functions
void reshapeCallback(GLFWwindow*, int, int);
void keyPressedCallback(GLFWwindow*, int, int, int, int);
void mousePassiveMotionCallback(GLFWwindow*, double, double);
void myMouseCallback(GLFWwindow*, int, int, int);
void scrollWheelCallback(GLFWwindow*, double, double);

// Graphical User Interface Functions
static inline void ShowTooltip(const char* text); // done
void createGUI();

// Utility Functions
float4 findCenterOfObject(); //done
void centerObject();//done
void rotateObject(float, int, int, int);//done
void translateObject(float, float, float);//done
void setSingleMuscleTypeAndColor(int); //done
void setAllMuscleTypesAndColors(); //done
bool isNodeInMouseSphere(int, float3); //done
int findClosestNodeToMouse(float3); //done
int getTypePriority(int); //done
float4 getColorFromType(int); //done
const char *getTimeStamp(); //done
void shutdownAndCleanup(); //done




