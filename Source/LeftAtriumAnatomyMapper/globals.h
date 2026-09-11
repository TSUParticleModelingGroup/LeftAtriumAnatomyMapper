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

// Node types
const int NodeTypeStandardLA = 0;
const int NodeTypeBachmannBundle = 1;
const int NodeTypeAppendage = 2;
const int NodeTypeScarTissue = 3; // This is not implemented yet but will be used to make scar tissue in the future.
const int NodeTypePulmonaryVeins = 4;
const int NodeTypeMitralValve = 5;
const int NodeTypeBackWall = 6;
const int NodeTypeExtraTissue = 7;

// Mouse modes, which will use the same int values as the node types for simplicity, but with -1 for off mode.
const int MouseModeOff = -1;
const int MouseModeStandardLA = NodeTypeStandardLA;
const int MouseModeBachmannsBundle = NodeTypeBachmannBundle;
const int MouseModeAppendage = NodeTypeAppendage;
const int MouseModeScarTissue = NodeTypeScarTissue; // This is not implemented yet but will be used to make scar tissue in the future.
const int MouseModePulmonaryVeins = NodeTypePulmonaryVeins;
const int MouseModeMitralValve = NodeTypeMitralValve;
const int MouseModeBackWall = NodeTypeBackWall;
const int MouseModeExtraTissue = NodeTypeExtraTissue;
const int MouseModePulseNode = 100; //BMW
const int MouseModeBackTop = 101; //BMW

// Color types
const float4 ColorStandardLA = {1.0f, 0.0f, 0.0f, 0.0f}; // Red for standard nodes (to reduce contrast)
const float4 ColorBachmannsBundle = {0.2f, 0.2f, 1.0f, 0.0f}; // Blue for Bachmann's Bundle nodes and muscles by default.
const float4 ColorAppendage = {1.0f, 0.8f, 0.3f, 0.0f}; // Orange for left atrial appendage nodes and muscles by default.
const float4 ColorScarTissue = {0.6f, 0.6f, 0.6f, 0.0f}; // Gray for scar tissue nodes and muscles by default.
const float4 ColorPulmonaryVeins = {1.0f, 0.4f, 0.7f, 0.0f}; // Pink for pulmonary veins nodes and muscles by default.
const float4 ColorMitralValve = {0.5f, 0.0f, 0.5f, 0.0f}; // Purple for mitral valve nodes and muscles by default.
const float4 ColorBackWall = {0.0f, 1.0f, 0.0f, 0.0f}; // Green for back wall nodes and muscles by default.
const float4 ColorExtraTissue = {0.6f, 0.6f, 0.6f, 0.0f}; // Gray for extra tissue nodes and muscles by default.

// ******************** Structures ************************************
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
	bool ShowMuscleTypesFlag;
	bool isInMouseFunctionMode; // This is true if the user is in any of the mouse function modes, like ablate mode, ectopic beat mode, adjust muscle area mode, or adjust muscle line mode.
	bool guiCollapsed; // for hotkey to collapse GUI
} simulationSwitchesStructure;

// Globals Start ******************************************

// How many nodes and muscle the simulation contains.
// They are read in form Raw or Bin files in the ConfigNodesMuscles folder.
int NumberOfNodes;
int NumberOfMuscles;

// These hold all the nodes and muscle structures.
// These are generated for raw files or read in from bin files.
nodeAttributesStructure *Node;
muscleAttributesStructure *Muscle;

// This will hold all the simulation switches.
// It is initialized in file_io.h/setRemainingParameters().
simulationSwitchesStructure Simulation;

// To use VBOs for sphere rendering
GLuint SphereVBO, SphereIBO; // Vertex Buffer Object and Index Buffer Object for sphere rendering, Vertex is the sphere's vertices and Index is the order in which to draw them.
GLuint NumSphereVertices, NumSphereIndices; // Number of vertices and indices in the sphere geometry

// This is the node that the beat initiates from and the two nodes along with the center that orients the object.
// They are initially read in form raw or bin files in the ConfigNodesMuscles folder.
int PulsePointNode = -1; // Set to -1 to flag it if it is used before it is set.
int ReferenceUpNode = -1; // Set to -1 to flag it if it is used before it is set.
int ReferenceBackNode = -1; // Set to -1 to flag it if it is used before it is set.
int ReferencePointNode = -1; // Set to -1 to flag it if it is used before it is set.
float4 ReferenceCenter = {0.0f, 0.0f, 0.0f, 0.0f};

// Holds the name of the medical view you are in for displaying in the terminal print.
char ViewName[256] = "no view set"; 

// Status line shown in GUI after saving binary files.
char BinarySaveStatusMessage[512] = "";

// These are all the globals that are read in from the ConfigSetup.
char NodesMusclesFileName[256];
float LineWidth;
float NodeRadiusAdjustment;
float NodePointSize;
float4 BackGround;


// This will hold the radius of the left atrium which we will use to scale the size of everything.
// It is calculated in findAverageRadiusOfObject().
// *** Should be stored if a runfile is saved.
double RadiusOfLeftAtrium = -1.0; // Set to -1.0 to flag it if it is used before it is set.

// Variable that holds mouse locations to be translated into positions in the simulation and mouse other functionality.
// They are initialized in setNodesAndMuscles.h/setRemainingParameters().
// TODO: Convert these to a float3 or double3
double MouseX, MouseY, MouseZ;
int MouseWheelPos;
float MouseSelectionRadiusMultiplier; // Adjusts how big of a region the mouse covers when you are selecting with it.
int ScrollSpeedToggle; // Sets slow or fast scroll speed.
double ScrollSpeed; // How fast your scroll moves.

// These keep track of where the view is as you zoom in and out and rotate.
// These are initialized in setNodesAndMuscles.h/setRemainingParameters().
// *** Should be stored if a runfile is saved.
float4 CenterOfSimulation;
float4 AngleOfSimulation;

// Window globals 
// They are all initialized in main().
GLFWwindow* Window; // Window pointer
int XWindowSize;
int YWindowSize; 
double Near; // Front and back of clip planes
double Far;
double EyeX; // Where your eye is
double EyeY;
double EyeZ;
double CenterX; // Where you are looking
double CenterY;
double CenterZ;
double UpX; // What up means to the viewer
double UpY;
double UpZ;

int Run = 1;

//*************** Function Prototypes **************************
// File input Functions
void readLAMAppingSetupParameters();  //Done
void readNodesFromRawFile(); //Done 
void readMusclesFromRawFile(); //Done
void readNodesAndMusclesFromBinaryFile(); //Done

// File Output Functions
void saveBinary();

// Setup Functions
void setup();
void checkNodes(); //done
void linkRawNodesToMuscles(); //done
double findAverageRadiusOfObject(); //done
void setMuscleNaturalLength(); //done

// User Action Functions
void setReferencePoints();//done
void toggleNodeSelector(simulationSwitchesStructure*, int);
void setMouseMode(simulationSwitchesStructure*, int);
void assignNodes(float3, int);

// View Functions
void ReferenceView();
void PAView();
void APView();
void setView(int);

// Draw Functions
void drawPicture();
void renderSphereVBO();
void renderSphere(float, int, int);
void createSphereVBO(float, int, int);

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




