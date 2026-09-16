
// Local include files
#include "globals.h"

/*
 In main we mostly just setup the openGL environment and kickoff the glutMainLoop function.
*/
int main(int argc, char** argv)
{
	setup();
	
	XWindowSize = 1800; //1800
	YWindowSize = 1000; //1000

	// Clip plains
	Near = 2.0; //0.2;
	Far = 400.0; //80.0*RadiusOfLeftAtrium;

	//Where your eye is located. It is important that this is a positive number, as the camera looks down the negative z axis. 
	EyeX = 0.0*RadiusOfLeftAtrium;
	EyeY = 0.0*RadiusOfLeftAtrium;
	EyeZ = 2.0*RadiusOfLeftAtrium; 

	//Where you are looking
	CenterX = 0.0;
	CenterY = 0.0;
	CenterZ = 0.0;

	//Up vector for viewing
	UpX = 0.0;
	UpY = 1.0;
	UpZ = 0.0;

	if(!glfwInit()) // Initialize GLFW, check for failure
	{
        	printf("\n Error: Failed to initialize GLFW\n");
        	return -1;
        }

	// Set compatibility mode to allow legacy OpenGL (this is just standard)
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2); //These 2 lines are for compatibility with older versions of OpenGL (2.1+) ensures backwards compatibility.
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_ANY_PROFILE); //This line is for compatibility with older versions of OpenGL.

	// Create a windowed mode window and its OpenGL context
	Window = glfwCreateWindow(XWindowSize, YWindowSize, "Left Atrium Mapping", NULL, NULL); // args: width, height, title, monitor, share

	if (!Window) 
	{
		printf("\n Error: Failed to create window\n");
		return -1;
	}

	// Make the window's context current
	glfwMakeContextCurrent(Window); // Make the window's context current, meaning that all future OpenGL commands will apply to this window.
	glfwSwapInterval(1); // Enable vsync (1 = on, 0 = off), vsync is a method used to prevent screen tearing which occurs when the GPU is rendering frames at a rate faster than the monitor can display them.

	if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))  // Initialize GLAD, check for failure
	{
		printf("\n Error: Failed to initialize GLAD\n");
		glfwTerminate();
		return -1;
	}

	glfwSetInputMode(Window, GLFW_STICKY_KEYS, GLFW_TRUE);

	//these set up our callbacks, most have been changed to adapters until GUI is implemented
	glfwSetFramebufferSizeCallback(Window, reshapeCallback);  //sets the callback for the window resizing
	glfwSetCursorPosCallback(Window, mousePassiveMotionCallback); //sets the callback for the cursor position
	glfwSetMouseButtonCallback(Window, myMouseCallback); //sets the callback for the mouse clicks
	glfwSetScrollCallback(Window, scrollWheelCallback); //sets the callback for the mouse wheel
	glfwSetKeyCallback(Window, keyPressedCallback); //sets the callback for the keyboard
	
	// Set the clear color to the background color
	glClearColor(BackGroundColor.x, BackGroundColor.y, BackGroundColor.z, 1.0f);

	//Lighting and material properties
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	//GLfloat light_position[] = {EyeX, EyeY, EyeZ, 0.0};
	GLfloat light_position[] = {1.0, 1.0, 1.0, 0.0}; //where the light is: {x,y,z,w}, w=0.0 is infinite light aiming at x,y,z, w=1.0 is a point light radiating from x,y,z
	GLfloat light_ambient[]  = {0.35, 0.35, 0.35, 1.0}; //what color is the ambient light, {r,g,b,a}, a= opacity 1.0 is fully visible, 0.0 is invisible
	GLfloat light_diffuse[]  = {0.35, 0.35, 0.35, 1.0}; //does light reflect off of the object, {r,g,b,a}, a has no effect
	GLfloat light_specular[] = {1.0, 1.0, 1.0, 1.0}; //does light highlight shiny surfaces, {r,g,b,a}. i.e what light reflects to viewer
	GLfloat lmodel_ambient[] = {0.5, 0.5, 0.5, 1.0}; //global ambient light, {r,g,b,a}, applies uniformly to all objects in the scene
	GLfloat mat_specular[]   = {1.0, 1.0, 1.0, 1.0}; //reflective properties of an object, {r,g,b,a}, highlights are currently white
	GLfloat mat_shininess[]  = {128.0}; //how shiny is the surface of an object, 0.0 is dull, 128.0 is very shiny
	glShadeModel(GL_SMOOTH);
	glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
	glLightfv(GL_LIGHT0, GL_POSITION, light_position);
	glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse);
	glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular);
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, lmodel_ambient);
	glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);
	glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess);

	glEnable(GL_COLOR_MATERIAL);
	glEnable(GL_DEPTH_TEST);

	//*****************************************Set up GUI********************************
	// Initialize ImGui
	IMGUI_CHECKVERSION();
	ImGui::CreateContext();
	ImGuiIO& io = ImGui::GetIO(); (void)io;
	io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;  // Enable keyboard controls

	// Setup ImGui style
	ImGui::StyleColorsDark();  // Choose a style (Light, Dark, or Classic)
	ImGuiStyle& style = ImGui::GetStyle(); // Get the current style
	style.Colors[ImGuiCol_WindowBg].w = 1.0f;  // Set window background color

	// Setup Platform/Renderer backends
	ImGui_ImplGlfw_InitForOpenGL(Window, true);  //connect ImGui to GLFW
	ImGui::GetIO().ConfigFlags |= ImGuiConfigFlags_NavNoCaptureKeyboard; //prevent ImGui from capturing keyboard input, allowing GLFW to handle it instead
	ImGui_ImplOpenGL3_Init("#version 130");      //Chooses OpenGL version 3.0, this is the version that is compatible with the current version of ImGui

	// Load a font
	io.Fonts->AddFontDefault();

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	

	//*****************************************End GUI Setup********************************


	createSphereVBO(NodeRadiusAdjustment * RadiusOfLeftAtrium, 10, 10); //the first arg was the radius used in the draw nodes flag

	// Get current size
	int width, height;
	glfwGetFramebufferSize(Window, &width, &height);
    
	// Update stored window size and set initial render size
	XWindowSize = width;
	YWindowSize = height;

	// Reset viewport and matrices to ensure proper initial state
	glViewport(0, 0, XWindowSize, YWindowSize);
    
	// Reset projection matrix
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	// Calculate aspect ratio using the render size
	float aspect = (float)XWindowSize / (float)YWindowSize;
	glFrustum(-aspect, aspect, -1.0, 1.0, Near, Far);
	
	// Reset modelview matrix
	// MODELVIEW MATRIX - this controls camera position
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity(); //Necessary here
	gluLookAt(EyeX, EyeY, EyeZ, CenterX, CenterY, CenterZ, UpX, UpY, UpZ);
	
	// Main loop
	while (Run == 1 && glfwWindowShouldClose(Window) == 0) // You need the glfwWindowShouldClose so when xing out of the window it will die.
	{
		glfwPollEvents();

		// Start ImGui frame
		ImGui_ImplOpenGL3_NewFrame();
		ImGui_ImplGlfw_NewFrame();
		ImGui::NewFrame();
		// Always draw every frame - this is critical for GLFW performance
		createImage();
		// Create and render GUI
		createGUI();
		ImGui::Render();
		ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
		glfwSwapBuffers(Window);
	}
	
	shutdownAndCleanup();
	return 0;
}

//******************* File Input Functions *****************************************

/*
 This function reads in the information in the user setup file "SetupLAMapping".
*/
void readLAMappingSetupParameters()
{
	ifstream data;
	string name;
	data.open("../SetupLAMapping");
	if(data.is_open() == 1)
	{
		getline(data,name,'=');
		data >> NodesMusclesFileName;
		
		getline(data,name,'=');
		data >> LineWidth;
		
		getline(data,name,'=');
		data >> NodeRadiusAdjustment;
		
		getline(data,name,'=');
		data >> NodePointSize;

		getline(data,name,'=');
		data >> BackGroundColor.x;
		
		getline(data,name,'=');
		data >> BackGroundColor.y;
		
		getline(data,name,'=');
		data >> BackGroundColor.z;
	}
	else
	{
		printf("\n Error: Could not open SetupLAMapping file.");
		printf("\n The simulation has been terminated.\n");
		exit(0);
	}
	
	data.close();
	printf("\n LaMapping Setup Parameters have been read in from SetupLAMapping file.\n");
}

/*
 This function 
 1. Opens a raw nodes file.
 2. Reads the number of nodes, the pulse node, the up node and the back node. 
    The reference node is set to be the same as the back node at this time.
 3. Allocates memory to hold the nodes on the CPU.
 4. Sets all the nodes to their default or start values.
 5. Reads and assigns the node positions from the node file.
*/
void readNodesFromRawFile()
{	
	FILE *inFile;
	float x, y, z;
	int id;
	char fileName[256];

	// 1: Opening the node file.
	// Generating the name of the file that holds the nodes.
	char directory[] = "../NodesMusclesLAMapping/raw/";
	strcpy(fileName, "");
	strcat(fileName, directory);
	strcat(fileName, NodesMusclesFileName);
	strcat(fileName, "/Nodes");
	inFile = fopen(fileName,"r");
	if(inFile == NULL)
	{
		printf("\n Error: Can't open Nodes file %s.", fileName);
		printf("\n The simulation has been terminated.\n");
		exit(0);
	}
	
	// 2: Reading the header information.
	fscanf(inFile, "%d", &NumberOfNodes);
	printf("\n NumberOfNodes = %d", NumberOfNodes);
	fscanf(inFile, "%d", &PulsePointNode);
	fscanf(inFile, "%d", &ReferenceUpNode);
	fscanf(inFile, "%d", &ReferenceBackNode);
	ReferencePointNode = ReferenceBackNode;
	
	
	// 3: Allocating memory for the nodes. 
	Node = (nodeAttributesStructure*)malloc(NumberOfNodes*sizeof(nodeAttributesStructure));
	
	// 4: Setting all nodes to their default settings; 
	for(int i = 0; i < NumberOfNodes; i++)
	{
		Node[i].position.x = 0.0;
		Node[i].position.y = 0.0;
		Node[i].position.z = 0.0;
		Node[i].position.w = 0.0;
		
		// Setting all node colors to white
		Node[i].color.x = 1.0;
		Node[i].color.y = 1.0;
		Node[i].color.z = 1.0;
		Node[i].color.w = 0.0;
		
		// Setting the type to 0 for all nodes. Type 0 is for a general LA node, which is what all nodes start out as.
		Node[i].type = 0; 
		
		// Sets all the muscle a node can connect to as -1 which indicates that not muscle is connect at this time.
		for(int j = 0; j < MUSCLES_PER_NODE; j++)
		{
			Node[i].muscle[j] = -1; 
		}
	}

	// 5: Reading in the nodes positions.
	for(int i = 0; i < NumberOfNodes; i++)
	{
		fscanf(inFile, "%d %f %f %f", &id, &x, &y, &z);

		Node[id].position.x = x;
		Node[id].position.y = y;
		Node[id].position.z = z;
		Node[id].color = ColorStandardLA;
	}
	
	fclose(inFile);
	printf("\n Nodes have been read in from raw file.\n");
}

/*
 This function 
 1. Opens a raw muscles file.
 2. Reads the number of muscles.
 3. Allocates memory to hold the muscles.
 4. Sets all the muscles to their default or start values.
 5. Reads and connects the muscle to the two nodes it is connected to.
*/
void readMusclesFromRawFile()
{	
	FILE *inFile;
	int id, idNode1, idNode2; //, muscleType;
	char fileName[256];
    
    	// 1: Opening the muscle file
	// Generating the name of the file that holds the muscles.
	char directory[] = "../NodesMusclesLAMapping/raw/";
	strcpy(fileName, "");
	strcat(fileName, directory);
	strcat(fileName, NodesMusclesFileName);
	strcat(fileName, "/Muscles");
	inFile = fopen(fileName,"r");
	if (inFile == NULL)
	{
		printf("\n Error: Can't open Muscles file %s.", fileName);
		printf("\n The simulation has been terminated.\n\n");
		exit(0);
	}
	
	// 2: Reading the number of muscles.
	fscanf(inFile, "%d", &NumberOfMuscles);
	printf("\n NumberOfMuscles = %d\n", NumberOfMuscles);
	
	// 3: Allocating memory for the muscles. 
	Muscle = (muscleAttributesStructure*)malloc(NumberOfMuscles*sizeof(muscleAttributesStructure));
	
	// 4: Setting all muscles to their default settings; 
	for(int i = 0; i < NumberOfMuscles; i++)
	{
		Muscle[i].type = 0;
		Muscle[i].nodeA = -1;
		Muscle[i].nodeB = -1;
		Muscle[i].naturalLength = -1.0; 
		Muscle[id].color = ColorStandardLA;
	}
	
	// Reading in from raw file what two nodes the muscle connects.
	// Format: id type nodeA nodeB
	for(int i = 0; i < NumberOfMuscles; i++)
	{
		if(fscanf(inFile, "%d %d %d", &id, &idNode1, &idNode2) != 3)
		{
			printf("\n Error: Invalid muscle format. Expected: id type nodeA nodeB.");
			printf("\n The simulation has been terminated.\n");
			exit(0);
		}
		
		if(id < 0 || NumberOfMuscles <= id)
		{
			printf("\n Error: You are trying to create a muscle that is out of bounds.");
			printf("\n The simulation has been terminated.\n");
			exit(0);
		}
		if(idNode1 < 0 || idNode2 < 0 || NumberOfNodes <= idNode1 || NumberOfNodes <= idNode2)
		{
			printf("\n Error: You are trying to connect to a node that is out of bounds.");
			printf("\n idNode1 = %d idNode2 = %d.", idNode1, idNode2);
			printf("\n The simulation has been terminated.\n");
			exit(0);
		}
		Muscle[id].type = 0;  // Default to LA muscle.
		Muscle[id].nodeA = idNode1;
		Muscle[id].nodeB = idNode2;
	}
	
	fclose(inFile);
	printf("\n Muscles have been read in from raw file.\n");
}

/*
 This function opens and read a binary nodes and muscles file.
 If NodesMusclesFileName contains .bin, it is treated as a filename under ../NodesMuscles/bin/.
 1. Opens the file.
 2. Reads the header information.
 3. Reads the nodes.
 4. Reads the muscles.
*/
void readNodesAndMusclesFromBinaryFile()
{
	FILE *inFile;
	char fileName[512];
	char *dot;

	// 1:
	strcpy(fileName, "../NodesMusclesLAMapping/bin/");
	strcat(fileName, NodesMusclesFileName);
	dot = strrchr(fileName, '.');
	if(dot == NULL || strcmp(dot, ".bin") != 0)
	{
		strcat(fileName, ".bin");
	}
	inFile = fopen(fileName, "rb");
	if(inFile == NULL)
	{
		printf("\n Error: Can't open binary file %s.", fileName);
		printf("\n The simulation has been terminated.\n");
		exit(0);
	}

	// 2:
	fread(&NumberOfNodes, sizeof(int), 1, inFile);
	fread(&NumberOfMuscles, sizeof(int), 1, inFile);
	fread(&PulsePointNode, sizeof(int), 1, inFile);
	fread(&ReferenceUpNode, sizeof(int), 1, inFile);
	fread(&ReferenceBackNode, sizeof(int), 1, inFile); 
	fread(&ReferencePointNode, sizeof(int), 1, inFile);
	fread(&ReferenceCenter, sizeof(float4), 1, inFile);

	// 3:
	Node = (nodeAttributesStructure*)malloc(NumberOfNodes*sizeof(nodeAttributesStructure));
	for(int i = 0; i < NumberOfNodes; i++)
	{
		fread(&Node[i].type, sizeof(int), 1, inFile);
		fread(&Node[i].position, sizeof(float4), 1, inFile);
		fread(Node[i].muscle, sizeof(int), MUSCLES_PER_NODE, inFile);
		fread(&Node[i].color, sizeof(float4), 1, inFile);
	}

	// 4:
	Muscle = (muscleAttributesStructure*)malloc(NumberOfMuscles*sizeof(muscleAttributesStructure));
	for(int i = 0; i < NumberOfMuscles; i++)
	{
		fread(&Muscle[i].type, sizeof(int), 1, inFile);
		fread(&Muscle[i].nodeA, sizeof(int), 1, inFile);
		fread(&Muscle[i].nodeB, sizeof(int), 1, inFile);
		fread(&Muscle[i].naturalLength, sizeof(float), 1, inFile);
		fread(&Muscle[i].color, sizeof(float4), 1, inFile);
	}

	fclose(inFile);
	printf("\n Binary file %s has been read in.\n", fileName);
}


//******************* File Output Functions ****************************************

/*
 This function:
 Saves run information "pulse node, viewing information" and the node/muscle particle structures to a binary file.
 I say particle structures because the simulation code will generate several more elements to the node and muscle 
 structures need to run the simulation.
 The file is written to:
 ../NodesMusclesLAMapping/bin/<NodesMusclesFileName>_<timestamp>.bin

 Binary layout:
 - NumberOfNodes int
 - NumberOfMuscles int
 - PulsePointNode int
 - ReferenceUpNode int
 - ReferenceBackNode int
 - ReferencePointNode int
 - ReferenceCenter float4
 - per node: type(int), position(float4), muscle[MUSCLES_PER_NODE](int), color(float4)
 - per muscle: type(int), nodeA(int), nodeB(int), naturalLength(float), color(float4)
*/
void saveBinary()
{
	FILE *binaryFile;
	char fileName[512];

	// Ensure all the muscles types are set before saving.
	setAllMuscleTypesAndColors();

	// Build output file path with timestamp suffix to avoid name collisions.
	const char *timeStamp = getTimeStamp();
	strcpy(fileName, "../NodesMusclesLAMapping/bin/");
	strcat(fileName, NodesMusclesFileName);
	strcat(fileName, "_");
	strcat(fileName, timeStamp);
	strcat(fileName, ".bin");

	// Open output file in binary write mode.
	binaryFile = fopen(fileName, "wb");
	if(binaryFile == NULL)
	{
		printf("\nError: Could not create binary file %s.\n", fileName);
		snprintf(SubGUIMessage, sizeof(SubGUIMessage), "Binary save failed: Could not create output file.");
		return;
	}

	// Save counts and pulseNode and orientation nodes.
	fwrite(&NumberOfNodes, sizeof(int), 1, binaryFile);
	fwrite(&NumberOfMuscles, sizeof(int), 1, binaryFile);
	fwrite(&PulsePointNode, sizeof(int), 1, binaryFile);
	fwrite(&ReferenceUpNode, sizeof(int), 1, binaryFile);
	fwrite(&ReferenceBackNode, sizeof(int), 1, binaryFile);
	fwrite(&ReferencePointNode, sizeof(int), 1, binaryFile);
	fwrite(&ReferenceCenter, sizeof(float4), 1, binaryFile);

	// Save nodes.
	for(int i = 0; i < NumberOfNodes; i++)
	{
		fwrite(&Node[i].type, sizeof(int), 1, binaryFile);
		fwrite(&Node[i].position, sizeof(float4), 1, binaryFile);
		fwrite(Node[i].muscle, sizeof(int), MUSCLES_PER_NODE, binaryFile); // Node to muscle connections.
		fwrite(&Node[i].color, sizeof(float4), 1, binaryFile);
	}

	// Save muscles.
	for(int i = 0; i < NumberOfMuscles; i++)
	{
		fwrite(&Muscle[i].type, sizeof(int), 1, binaryFile);
		fwrite(&Muscle[i].nodeA, sizeof(int), 1, binaryFile);
		fwrite(&Muscle[i].nodeB, sizeof(int), 1, binaryFile);
		fwrite(&Muscle[i].naturalLength, sizeof(float), 1, binaryFile);
		fwrite(&Muscle[i].color, sizeof(float4), 1, binaryFile);
	}

	// Close file handle before reporting success.
	fclose(binaryFile);
	printf("\n Binary file has been saved: %s\n", fileName);
	
	// Placing message on GUI so user knows the file has been saved.
	strcpy(SubGUIMessage, "Binary File Saved");
}

//******************* Setup Functions **********************************************

void setup()
{	
	readLAMappingSetupParameters();
	
	char *extension = strrchr(NodesMusclesFileName, '.');
	bool isBinaryInput = (extension != NULL && strcmp(extension, ".bin") == 0);

	// LAMapping input mode is selected by file extension in NodesMusclesFileName.
	if(isBinaryInput)
	{
		readNodesAndMusclesFromBinaryFile();
	}
	else
	{
		readNodesFromRawFile();	
		checkNodes();
		readMusclesFromRawFile();
		linkRawNodesToMuscles();
		setMuscleNaturalLength();
		setAllMuscleTypesAndColors();
	}
	
	centerObject();
	RadiusOfLeftAtrium = findAverageRadiusOfObject();
	
	CenterOfSimulation.x = 0.0;
	CenterOfSimulation.y = 0.0;
	CenterOfSimulation.z = 0.0;
	CenterOfSimulation.w = 0.0;
		
	AngleOfSimulation.x = 0.0;
	AngleOfSimulation.y = 1.0;
	AngleOfSimulation.z = 0.0;
	AngleOfSimulation.w = 0.0;

	Simulation.mouseMode = MouseModeStandardLA;
	Simulation.DrawNodesFlag = 0;
	Simulation.DrawFrontHalfFlag = 0;
	Simulation.isInMouseFunctionMode = false;
	Simulation.guiCollapsed = false;
	
	// Initial lacation of the slection sphere.
	MouseZ = RadiusOfLeftAtrium;
	MouseX = 0.0;
	MouseY = 0.0;
	MouseSelectionRadiusMultiplier = 0.1;
	
	// Scroll wheel speeds and toggle.
	ScrollSpeedToggle = 1;
	ScrollSpeedFast = 1.0;
	ScrollSpeedSlow = 0.1;
	ScrollSpeed = ScrollSpeedFast;
	
	printf("\n Have a good simulation.\n");
}

/* 
 This function:
 Checks to see if two nodes are too close together relative to all the other node seperations. 
   1: This for loop finds all the nearest neighbor distances and then it calculates the average of this value. 
      This get a sense of how close nodes are in general. If you have more nodes they are going to be 
      closer together, this number just gets you a scale to compare to.
   2: This for loop checks to see if two nodes are closer than an cutoffDivider times smaller than the 
      average minimal seperation distance. If it is, the nodes in question are printed out with their separation and a flag is set.
      Adjust the cutoffDivider for tighter and looser tolerances.
   3: If the flag is set, the simulation is terminated so the user can correct the node file that contains the faulty nodes.
*/
void checkNodes()
{
	float dx, dy, dz, d;
	float averageMinSeparation, minSeparation;
	bool flag;
	float cutoffDivider = 100.0;
	float cutoff;
	
	// 1: Finding average nearest neighbor distance.
	averageMinSeparation = 0;
	for(int i = 0; i < NumberOfNodes; i++)
	{
		minSeparation = FLOATMAX; // Setting min as a huge value just to get it started.
		for(int j = 0; j < NumberOfNodes; j++)
		{
			if(i != j)
			{
				dx = Node[i].position.x - Node[j].position.x;
				dy = Node[i].position.y - Node[j].position.y;
				dz = Node[i].position.z - Node[j].position.z;
				d = sqrt(dx*dx + dy*dy + dz*dz);
				if(d < minSeparation) 
				{
					minSeparation = d;
				}
			}
		}
		averageMinSeparation += minSeparation;
	}
	averageMinSeparation = averageMinSeparation/NumberOfNodes;
	
	// 2: Checking to see if nodes are too close together.
	cutoff = averageMinSeparation/cutoffDivider;
	flag = false;
	for(int i = 0; i < NumberOfNodes; i++)
	{
		for(int j = 0; j < NumberOfNodes; j++)
		{
			if(i != j)
			{
				dx = Node[i].position.x - Node[j].position.x;
				dy = Node[i].position.y - Node[j].position.y;
				dz = Node[i].position.z - Node[j].position.z;
				d = sqrt(dx*dx + dy*dy + dz*dz);
				if(d < cutoff)
				{
					printf("\n Nodes %d and %d are too close. Their separation is %f\n", i, j, d);
					//printf("\n (%f, %f, %f)", Node[i].position.x, Node[i].position.y, Node[i].position.z);
					//printf("\n (%f, %f, %f)", Node[j].position.x, Node[j].position.y, Node[j].position.z);
					//printf("\n");
					flag = true;
				}
			}
		}
	}
	
	// 3: Terminating the simulation if nodes were flagged.
	if(flag == true)
	{
		printf("\n Error: The average nearest separation for all the nodes is %f.", averageMinSeparation);
		printf("\n The cutoff separation is %f.", cutoff);
		printf("\n The simulation has been terminated.\n\n");
		exit(0);
	}
	
	printf("\n Nodes have been checked for minimal separation.\n");
}

/*
 This function: 
 Loads each node structure with all the muscles it is connected to.
*/
void linkRawNodesToMuscles()
{	
	int k;
	// Each node will have a list of the muscles it is attached to.
	for(int i = 0; i < NumberOfNodes; i++)
	{
		k = 0;
		for(int j = 0; j < NumberOfMuscles; j++)
		{
			if(Muscle[j].nodeA == i || Muscle[j].nodeB == i) // Checking to see if either end of the muscle is attached to node i.
			{
				if(MUSCLES_PER_NODE < k) // Making sure we do not go out of bounds.
				{
					printf("\n Error: Number of muscles connected to node %d is larger than the allowed number of", i);
					printf("\n muscles connected to a single node.");
					printf("\n If this is not a mistake increase MUSCLES_PER_NODE in the header.h file.");
					printf("\n The simulation has been terminated.\n");
					exit(0);
				}
				Node[i].muscle[k] = j;
				k++;
			}
		}
	}
	printf("\n Nodes have been linked to muscles. \n");
}

/*
 This funciton: 
 Finds the average radius of the object by: 
 1. Finding the center of the object.
 2. Finding the distance from each node to the center, which is the radius of that node.
 3. Averages all those radii together to get the average radius of the object.
 4. Returns that number.
*/
double findAverageRadiusOfObject() 
{
	double averageRadius;
	float4 centerOfObject = findCenterOfObject();

	// Calculate the distance from each node to the center
	float totalRadius = 0.0f;
	for (int i=0; i < NumberOfNodes; i++)
	{
		float dx = Node[i].position.x - centerOfObject.x;
		float dy = Node[i].position.y - centerOfObject.y;
		float dz = Node[i].position.z - centerOfObject.z;
		float distance = sqrtf(dx*dx + dy*dy + dz*dz);
		totalRadius += distance;
	}

	averageRadius = totalRadius/NumberOfNodes;
	printf("\n The average radius of the object is %f mm\n", averageRadius); // The average radius for RealisticLA is around 25.8 mm
	return averageRadius;
}

/*
 These function: 
 Sets the natural length of the muscles to be used down stream in the model simulation. 
*/
void setMuscleNaturalLength()
{	
	double dx, dy, dz;
	for(int i = 0; i < NumberOfMuscles; i++)
	{	
		dx = Node[Muscle[i].nodeA].position.x - Node[Muscle[i].nodeB].position.x;
		dy = Node[Muscle[i].nodeA].position.y - Node[Muscle[i].nodeB].position.y;
		dz = Node[Muscle[i].nodeA].position.z - Node[Muscle[i].nodeB].position.z;
		Muscle[i].naturalLength = sqrt(dx*dx + dy*dy + dz*dz);
		
	}
		
	printf("\n Muscle natural lengths have been set.\n");
}

//******************* User Action Functions ********************************************

/*
 This function will:
 1. Find the node that is closest to being directly above the center of the object (the UpNode).
 2. Find the node that is closest to the user from the center of the object (the BackNode).
    It is called the BackNode because in the reference view which all views are related to you are looking at
    the bacl of the LA. The UpNode and BackNodes should be set when you are in this view.

 3. Set the ReferenceUpNode ReferenceBackNode, and ReferenceCenter.
*/
void setReferencePoints()
{
	float dx, dy, dz, radiusSquared, minRadius;
	float4 center;
	int upId, backId;
	
	// 1:
	minRadius = FLOATMAX;
	upId = -1;
	for(int i = 0; i < NumberOfNodes; i++)
	{
		if(center.y < Node[i].position.y)
		{
			dx = center.x - Node[i].position.x;
			dz = center.z - Node[i].position.z;
			radiusSquared = dx*dx + dz*dz;
			if(radiusSquared < minRadius) 
			{
				upId = i;
				minRadius = radiusSquared;
			}
		}
	}
	if(upId == -1)
	{
		printf("\n Error: Could not find ReferenceUpNode.");
		printf("\n The Simulation has been terminated!\n");
		exit(0);
	}
	
	// 2:
	backId = -1;
	minRadius = FLOATMAX;
	for(int i = 0; i < NumberOfNodes; i++)
	{
		if(center.z < Node[i].position.z)
		{
			radiusSquared = Node[i].position.x*Node[i].position.x + Node[i].position.y*Node[i].position.y;
			dx = center.x - Node[i].position.x;
			dy = center.y - Node[i].position.y;
			radiusSquared = dx*dx + dy*dy;
			if(radiusSquared < minRadius) 
			{
				backId = i;
				minRadius = radiusSquared;
			}
		}
	}
	if(backId == -1)
	{
		printf("\n Error: Could not find ReferenceBackNode.");
		printf("\n The Simulation has been terminated!\n");
		exit(0);
	}
	
	// 3:
	ReferenceUpNode = upId;
	ReferenceBackNode = backId;
	ReferenceCenter = center;
	
	printf("\n ReferenceUpNode, ReferenceBackNode, and  ReferenceCenter have been set.\n");
}

void assignNodes(float3 mousePos, int nodeType)
{
	for(int i = 0; i < NumberOfNodes; i++)
	{
		if(isNodeInMouseSphere(i, mousePos) == true)
		{
			Node[i].type = nodeType;
			Node[i].color = getColorFromType(nodeType);
			for(int j = 0; j < MUSCLES_PER_NODE; j++)
			{
				if(Node[i].muscle[j] != -1)
				{
					Muscle[Node[i].muscle[j]].color = getColorFromType(nodeType);
				}
			}
		}
	}
}

//******************* View Functions ***********************************************

/*
 This function: 
 Puts the viewer in the reference view. The reference view is looking straight at the four
 pulmonary veins with a vein in each of the four quadrants of the x-y plane as symmetric as you can make 
 it with the mitral valve down. We base all the other views off of this view.
*/
void ReferenceView()
{	
	float angle, temp;
	centerObject();
		
	// Rotating until the up Node is on x-y plane above or below the positive x-axis.
	angle = atan(Node[ReferenceUpNode].position.z/Node[ReferenceUpNode].position.x);
	if(Node[ReferenceUpNode].position.x < 0.0) angle -= PI;
	for(int i = 0; i < NumberOfNodes; i++)
	{
		temp = cos(angle)*Node[i].position.x + sin(angle)*Node[i].position.z;
		Node[i].position.z  = -sin(angle)*Node[i].position.x + cos(angle)*Node[i].position.z;
		Node[i].position.x  = temp;
	}
	AngleOfSimulation.y += angle;
	
	// Rotating until up Node is on the positive y axis.
	angle = PI/2.0 - atan(Node[ReferenceUpNode].position.y/Node[ReferenceUpNode].position.x);
	for(int i = 0; i < NumberOfNodes; i++)
	{
		temp = cos(angle)*Node[i].position.x - sin(angle)*Node[i].position.y;
		Node[i].position.y  = sin(angle)*Node[i].position.x + cos(angle)*Node[i].position.y;
		Node[i].position.x  = temp;
	}
	AngleOfSimulation.z += angle;
	
	// Rotating until front Node is on the positive z axis.
	angle = atan(Node[ReferenceBackNode].position.z/Node[ReferenceBackNode].position.x) - PI/2.0;
	if(Node[ReferenceBackNode].position.x < 0.0) angle -= PI;
	for(int i = 0; i < NumberOfNodes; i++)
	{
		temp = cos(angle)*Node[i].position.x + sin(angle)*Node[i].position.z;
		Node[i].position.z  = -sin(angle)*Node[i].position.x + cos(angle)*Node[i].position.z;
		Node[i].position.x  = temp;
	}
	AngleOfSimulation.y += angle;
}

/*
 This function puts the LA in the PA view.
 The heart does not set in the chest at a straight on angle. Hence we need to adjust our 
 reference view to what is actually seen in a back view looking through the chest.
*/
void PAView()
{  
	float angle;
	
	ReferenceView();
	
	angle = PI/6.0; // Rotate 30 degrees counterclockwise on the y-axis 
	//rotateYAxis(angle);
	rotateObject(angle, 0, 1, 0);

	angle = PI/6.0; // Rotate 30 degrees counterclockwise on the z-axis
	//rotateZAxis(angle);
	rotateObject(angle, 0, 0, 1);
}

/*
 This function puts the LA in the AP view.
 To get the AP view we just rotate the PA view 180 degrees on the y-axis

*/
void APView()
{ 
	float angle;
	
	PAView();
	angle = PI; // Rotate 180 degrees counterclockwise on the y-axis 
	//rotateYAxis(angle);
	rotateObject(angle, 0, 1, 0);
}

/*
 This function sets all the views based off of the reference view and the AP view.
*/
void setView(int view)
{
	if(view == 6)
	{
		ReferenceView();
		strcpy(ViewName, "Ref");
	}
	else if(view == 4)
	{
		PAView();
		strcpy(ViewName, "PA");
	}
	else if(view == 2)
	{
		APView();
		strcpy(ViewName, "AP");
	}
	else if(view == 3)
	{
		APView();
		//rotateYAxis(-PI/6.0);
		rotateObject(-PI/6.0, 0, 1, 0);
		strcpy(ViewName, "RAO");
	}
	else if(view == 1)
	{
		APView();
		//rotateYAxis(PI/3.0);
		rotateObject(PI/3.0, 0, 1, 0);
		strcpy(ViewName, "LAO");
	}
	else if(view == 7)
	{
		APView();
		//rotateYAxis(PI/2.0);
		rotateObject(PI/2.0, 0, 1, 0);
		strcpy(ViewName, "LL");
	}
	else if(view == 9)
	{
		APView();
		//rotateYAxis(-PI/2.0);
		rotateObject(-PI/2.0, 0, 1, 0);
		strcpy(ViewName, "RL");
	}
	else if(view == 8)
	{
		APView();
		//rotateXAxis(PI/2.0);
		rotateObject(PI/2.0, 1, 0, 0);
		strcpy(ViewName, "SUP");
	}
	else if(view == 5)
	{
		APView();
		//rotateXAxis(-PI/2.0);
		rotateObject(-PI/2.0, 1, 0, 0);
		strcpy(ViewName, "INF");
	}
	else
	{
		printf("\n Undefined view reverting back to Ref view.\n");
		ReferenceView();
		strcpy(ViewName, "Ref");
	}
}

//******************* Draw Functions ***********************************************

/*
 This function:
 Creates the LA image.
*/
void createImage()
{
	//int nodeNumber;
	int muscleNumber;
	int k;
	glClear(GL_COLOR_BUFFER_BIT);
	glClear(GL_DEPTH_BUFFER_BIT);
	
	glColor3d(Node[PulsePointNode].color.x, Node[PulsePointNode].color.y, Node[PulsePointNode].color.z);
	glPushMatrix();
	glTranslatef(Node[PulsePointNode].position.x, Node[PulsePointNode].position.y, Node[PulsePointNode].position.z);
	renderSphereVBO();
	glPopMatrix();
	
	// Drawing center node
	//This draws a node at the center of the simulation for debugging purposes
	if(false) // false turns it off, true turns it on.
	{
		glColor3d(0.0,0.0,1.0);
		glPushMatrix();
		glTranslatef(CenterOfSimulation.x, CenterOfSimulation.y, CenterOfSimulation.z);
		renderSphereVBO();
		glPopMatrix();
	}
	
	// Drawing nodes
	if(Simulation.DrawNodesFlag == 1 || Simulation.DrawNodesFlag == 2)  //if we're drawing half(1) or all(2) of the nodes
	{
		for(int i = 0; i < NumberOfNodes; i++) // Start at 1 to skip the pulse node and go through all nodes
		{
			if(Simulation.DrawFrontHalfFlag == 1 || Simulation.DrawNodesFlag == 1) //If we're only drawing the nodes on the front half.
			{
				if(CenterOfSimulation.z - 0.001 < Node[i].position.z)  //Draw only the nodes in the front half.
				{
					glColor3d(Node[i].color.x, Node[i].color.y, Node[i].color.z);
					glPushMatrix();
					glTranslatef(Node[i].position.x, Node[i].position.y, Node[i].position.z);
					renderSphereVBO();
					glPopMatrix();
				}
			}
			else //draw all nodes
			{
				glColor3d(Node[i].color.x, Node[i].color.y, Node[i].color.z);
				glPushMatrix();
				glTranslatef(Node[i].position.x, Node[i].position.y, Node[i].position.z);
				renderSphereVBO();
				glPopMatrix();
			}	
		}
	}
	// If the nodes are not drawn as spheres you will be in this else case.
	// Now some of the node we still draw as points, like node that have been ablated, ectopic nodes, or nodes connected to muscle
	// that have been adjusted. This helps the user keep track of what has been done. This is what is done here and is based on
	// the .isDrawNode flag.
	else 
	{
		glPointSize(NodePointSize);
		glBegin(GL_POINTS);
	 	for(int i = 0; i < NumberOfNodes; i++)
		{
			if(Simulation.DrawFrontHalfFlag == 1)
			{
				if(CenterOfSimulation.z - 0.001 < Node[i].position.z)  // Only drawing the nodes in the front half.
				{
					glColor3d(Node[i].color.x, Node[i].color.y, Node[i].color.z);
				}
			}
			else
			{
				glColor3d(Node[i].color.x, Node[i].color.y, Node[i].color.z);
			}
		}
		glEnd();
	}

	// Always draw PulsePointNode, UpNode, BackNode, and ReferenceNode as point sprites so they stand out regardless of node draw mode.
	glPointSize(NodePointSize * 1.35f);
	glBegin(GL_POINTS);
		
		glColor3d(1.0, 0.85, 0.2);
		glVertex3f(Node[PulsePointNode].position.x, Node[PulsePointNode].position.y, Node[PulsePointNode].position.z);
		
		glColor3d(0.2, 0.95, 1.0);
		glVertex3f(Node[ReferenceUpNode].position.x, Node[ReferenceUpNode].position.y, Node[ReferenceUpNode].position.z);
		
		glColor3d(1.0, 0.45, 0.2);
		glVertex3f(Node[ReferenceBackNode].position.x, Node[ReferenceBackNode].position.y, Node[ReferenceBackNode].position.z);
		
		glColor3d(1.0, 0.45, 1.0);
		glVertex3f(Node[ReferencePointNode].position.x, Node[ReferencePointNode].position.y, Node[ReferencePointNode].position.z);
		
		float4 center = findCenterOfObject();
		glColor3d(0.0, 0.0, 1.0);
		glVertex3f(center.x, center.y, center.z);
		
	glEnd();
	
	// Drawing muscles
	glLineWidth(LineWidth);
	for(int i = 0; i < NumberOfNodes; i++)
	{
		for(int j = 0; j < MUSCLES_PER_NODE; j++)
		{
			muscleNumber = Node[i].muscle[j];
			if(muscleNumber != -1)
			{
				k = Muscle[muscleNumber].nodeA;
				if(k == i) 
				{
					k = Muscle[muscleNumber].nodeB;
				}
				
				if(Simulation.DrawFrontHalfFlag == 1)
				{
					if(CenterOfSimulation.z - 0.001 < Node[i].position.z && CenterOfSimulation.z - 0.001 < Node[k].position.z)  // Only drawing the nodes in the front half.
					{
						glColor3d(Muscle[muscleNumber].color.x, Muscle[muscleNumber].color.y, Muscle[muscleNumber].color.z);
						glBegin(GL_LINES);
							glVertex3f(Node[i].position.x, Node[i].position.y, Node[i].position.z);
							glVertex3f(Node[k].position.x, Node[k].position.y, Node[k].position.z);
						glEnd();
					}
				}
				else
				{
					glColor3d(Muscle[muscleNumber].color.x, Muscle[muscleNumber].color.y, Muscle[muscleNumber].color.z);
					glBegin(GL_LINES);
						glVertex3f(Node[i].position.x, Node[i].position.y, Node[i].position.z);
						glVertex3f(Node[k].position.x, Node[k].position.y, Node[k].position.z);
					glEnd();
				}
			}
		}	
	}
	
	// Puts a ball at the location of the mouse if a mouse function is on.
	if (Simulation.isInMouseFunctionMode)
	{
		glColor3d(1.0,1.0,1.0);
		glPushMatrix();
		glTranslatef(MouseX, MouseY, MouseZ);	
		renderSphere(MouseSelectionRadiusMultiplier*RadiusOfLeftAtrium,20,20);
		glPopMatrix();
	}
}

/*
 This function:
 Creates spheres use for the body of the LA. Created once and stored so they are much faster.
*/
void renderSphereVBO() 
{
	// Bind the VBO and IBO
	glBindBuffer(GL_ARRAY_BUFFER, SphereVBO);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, SphereIBO);

	// Enable vertex and normal arrays
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);

	// Set up pointers to vertex and normal data
	glVertexPointer(3, GL_FLOAT, 6 * sizeof(float), 0);
	glNormalPointer(GL_FLOAT, 6 * sizeof(float), (void*)(3 * sizeof(float)));

	// Draw the sphere
	glDrawElements(GL_TRIANGLES, NumSphereIndices, GL_UNSIGNED_INT, 0);

	// Disable arrays
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);

	// Unbind buffers
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}


// Add this to a utility file, only used for the mouse selection since it's just 1 object
/*
 This function:
 Creates a single sphere created for the mouse which can change. It is slower but it is just one sphere.
*/
void renderSphere(float radius, int slices, int stacks) 
{
    // Sphere geometry parameters
    float x, y, z, alpha, beta; // Storage for coordinates and angles
    float sliceStep = 2.0f * PI / slices;
    float stackStep = PI / stacks;

    for (int i = 0; i < stacks; ++i) 
    {
        alpha = i * stackStep;
        beta = alpha + stackStep;

        glBegin(GL_TRIANGLE_STRIP);
        for (int j = 0; j <= slices; ++j) 
        {
            float theta = (j == slices) ? 0.0f : j * sliceStep;

            // Vertex 1
            x = -sin(alpha) * cos(theta);
            y = cos(alpha);
            z = sin(alpha) * sin(theta);
            glNormal3f(x, y, z);
            glVertex3f(x * radius, y * radius, z * radius);

            // Vertex 2
            x = -sin(beta) * cos(theta);
            y = cos(beta);
            z = sin(beta) * sin(theta);
            glNormal3f(x, y, z);
            glVertex3f(x * radius, y * radius, z * radius);
        }
        glEnd();
    }
}

/*
 This function:
 Creates spheres used for the body of the LA. Created once and stored so they are much faster.
*/
void createSphereVBO(float radius, int slices, int stacks)
{
    std::vector<float> vertices;
    std::vector<unsigned int> indices;
    
	// Generate sphere vertices with positions and normals
	for (int i = 0; i <= stacks; ++i) 
	{
		// Calculate the vertical angle phi (0 to PI, from top to bottom of sphere)
		float phi = PI * i / stacks;
		float sinPhi = sin(phi);
		float cosPhi = cos(phi);
		
		for (int j = 0; j <= slices; ++j) 
		{
			// Calculate the horizontal angle theta (0 to 2PI, around the sphere)
			float theta = 2.0f * PI * j / slices;
			float sinTheta = sin(theta);
			float cosTheta = cos(theta);
			
			// Convert spherical to Cartesian coordinates
			// x = r * sin(phi) * cos(theta)
			// y = r * cos(phi)          // y is up/down axis (poles of the sphere)
			// z = r * sin(phi) * sin(theta)
			float x = radius * sinPhi * cosTheta;

			float y = radius * cosPhi;
			float z = radius * sinPhi * sinTheta;
			
			// For a sphere, normal vectors point outward from center
			// and are simply the normalized position vector (position/radius)
			float nx = sinPhi * cosTheta;  // Same as x/radius
			float ny = cosPhi;             // Same as y/radius
			float nz = sinPhi * sinTheta;  // Same as z/radius
			
			// Store the vertex data in interleaved format:
			// Each vertex has 6 floats - 3 for position (x,y,z) and 3 for normal (nx,ny,nz)
			vertices.push_back(x);
			vertices.push_back(y);
			vertices.push_back(z);
			vertices.push_back(nx);
			vertices.push_back(ny);
			vertices.push_back(nz);
		}
	}
    
	// Generate indices for triangle strips
	// This section creates triangles by connecting the grid of vertices:
	// - First defines index values that point to positions in the vertex array 
	// - Creates two triangles for each grid cell (rectangular patch)
	// - Each triangle is defined by three indices in counter-clockwise order
	for (int i = 0; i < stacks; ++i) 
	{
		for (int j = 0; j < slices; ++j) 
		{
			// Calculate indices for the four corners of the current grid cell
			int first = i * (slices + 1) + j;          // Current vertex
			int second = first + slices + 1;           // Vertex below current
			
			// First triangle: Connect current vertex, vertex below, and vertex to the right
			indices.push_back(first);
			indices.push_back(second);
			indices.push_back(first + 1);
			
			// Second triangle: Connect vertex below, vertex below+right, and vertex to the right
			indices.push_back(second);
			indices.push_back(second + 1);
			indices.push_back(first + 1);
		}
	}

	// Store the total counts for rendering
	NumSphereVertices = vertices.size() / 6; // 6 floats per vertex (pos + normal)
	NumSphereIndices = indices.size();

	// Create and setup OpenGL buffers on the GPU
	// - Generate unique buffer IDs
	// - Bind buffers to set them as active
	// - Copy data from CPU arrays to GPU memory
	glGenBuffers(1, &SphereVBO);  // Generate Vertex Buffer Object for storing positions and normals
	glBindBuffer(GL_ARRAY_BUFFER, SphereVBO);
	glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(float), vertices.data(), GL_STATIC_DRAW);

	// Same process for the index buffer
	glGenBuffers(1, &SphereIBO);  // Generate Index Buffer Object for storing triangle connections
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, SphereIBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(unsigned int), indices.data(), GL_STATIC_DRAW);

	// Unbind buffers to prevent accidental modification
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

/*
 This function:
 Takes a screenshot of the LA Image.
*/
void screenShot()
{	
	FILE* ScreenShotFile;
	unsigned char* buffer; //unsigned char because we are using RGBA data, which is 4 bytes per pixel, 1 char = 1 byte

	char cmd[512];

	const char *timeStamp = getTimeStamp();
	sprintf(cmd, "ffmpeg -loglevel error -f rawvideo -pix_fmt rgba -s %dx%d -i - -frames:v 1 -vf \"scale=%d:%d,vflip\" -c:v png \"../ScreenShots/%s.png\"", 
				XWindowSize, YWindowSize, XWindowSize, YWindowSize, timeStamp );
	
	ScreenShotFile = popen(cmd, "w");
	buffer = (unsigned char*)malloc(4 * XWindowSize * YWindowSize);
	
	createImage();
	glReadPixels(0, 0, XWindowSize, YWindowSize, GL_RGBA, GL_UNSIGNED_BYTE, buffer);   
	fwrite(buffer, 4 * XWindowSize * YWindowSize, 1, ScreenShotFile);
	
	pclose(ScreenShotFile);
	free(buffer);
	
	strcpy(SubGUIMessage, "Screenshot Saved");
	printf("\nScreenshot Captured: \n");
}

//******************* Callback Functions ***********************************************

/*
 Callback when the window is reshaped.
*/
void reshapeCallback(GLFWwindow* window, int width, int height)
{
	// Update the window size variables for capture and mouse math
	XWindowSize = width;
	YWindowSize = height;

	glViewport(0, 0, width, height); // Set the viewport size to match the window size
}

/*
 OpenGL callback when a key is pressed.
 It's actions are: GLFW_PRESS, GLFW_REPEAT, and GLFW_RELEASE.
*/
void keyPressedCallback(GLFWwindow* window, int key, int scancode, int action, int mods)
{
	float dAngle = 0.01;
	float dx,dy,dz;
	dx = dy = dz = 0.01*RadiusOfLeftAtrium;
	
	// Tab always toggles GUI mode <-> mouse mode, even when GUI currently has focus.
	if(action == GLFW_PRESS && key == GLFW_KEY_TAB)
	{
		if (Simulation.isInMouseFunctionMode == true)
		{
			Simulation.isInMouseFunctionMode = false;
			Simulation.guiCollapsed = false;
			Simulation.mouseMode = NodeTypeStandardLA;
			glfwSetInputMode(Window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
		}
		else
		{
			Simulation.isInMouseFunctionMode = true;
			Simulation.guiCollapsed = true;
			Simulation.mouseMode = NodeTypeStandardLA;
			glfwSetInputMode(Window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
		}
		return;
	}
        
        // X-axis Translations and Rotations
        if(key == GLFW_KEY_X && (action == GLFW_PRESS || action == GLFW_REPEAT))
        {
        	if((mods & GLFW_MOD_CONTROL) && (mods & GLFW_MOD_SHIFT)) rotateObject(-dAngle, 1, 0, 0);
		else if(mods == GLFW_MOD_SHIFT) translateObject(dx, 0.0, 0.0);
		else if(mods == GLFW_MOD_CONTROL) rotateObject(dAngle, 1, 0, 0);
		else translateObject(-dx, 0.0, 0.0);
        }
        
        // Y-axis Translations and Rotations
        if(key == GLFW_KEY_Y && (action == GLFW_PRESS || action == GLFW_REPEAT))
        {
        	if((mods & GLFW_MOD_CONTROL) && (mods & GLFW_MOD_SHIFT)) rotateObject(dAngle, 0, 1, 0);
		else if(mods == GLFW_MOD_SHIFT) translateObject(0.0, dy, 0.0);
		else if(mods == GLFW_MOD_CONTROL) rotateObject(-dAngle, 0, 1, 0);
		else translateObject(0.0, -dy, 0.0);
        }
        
        // Z-axis Translations and Rotations
        if(key == GLFW_KEY_Z && (action == GLFW_PRESS || action == GLFW_REPEAT))
        {
        	if((mods & GLFW_MOD_CONTROL) && (mods & GLFW_MOD_SHIFT)) rotateObject(-dAngle, 0, 0, 1);
		else if(mods == GLFW_MOD_SHIFT) translateObject(0.0, 0.0, dz);
		else if(mods == GLFW_MOD_CONTROL) rotateObject(dAngle, 0, 0, 1);
		else translateObject(0.0, 0.0, -dz);
        }
        
	// See if GUI wants this event (prevents shortcuts while typing in text fields).
	ImGuiIO& io = ImGui::GetIO();
	if (io.WantCaptureKeyboard)
        return;

	// Only process key press events, not releases or repeats

	if (action != GLFW_PRESS) return;

	// Check for specific key presses
	switch (key)
	{
		case GLFW_KEY_ESCAPE: // Escape key to exit
			Run = 0;
			break;

		case GLFW_KEY_KP_SUBTRACT: // Decrease selector size
			MouseSelectionRadiusMultiplier -= 0.01f;
			if(MouseSelectionRadiusMultiplier < 0.01f) MouseSelectionRadiusMultiplier = 0.01f;
			break;

		case GLFW_KEY_KP_ADD: // Increase selector size
			MouseSelectionRadiusMultiplier += 0.025f;
			if(MouseSelectionRadiusMultiplier > 0.5f) MouseSelectionRadiusMultiplier = 0.5f;
			break;
		default: // For any other key, do nothing
			break;

	}
}

/*
 This function is called when the mouse moves without any button pressed.
 x and y are the current mouse coordinates.
 x come in as (0, XWindowSize) and y comes in as (0, YWindowSize). 
 We translates them to MouseX (-1, 1) and MouseY (-1, 1) to corospond to the openGL window size.
 We then use MouseX and MouseY to determine where the mouse is in the simulation.
*/
void mousePassiveMotionCallback(GLFWwindow* window, double x, double y)
{
	// Get ImGui IO to check if mouse is over ImGui windows
	ImGuiIO& io = ImGui::GetIO();

	//Show cursor when highlighting over IMGUI elements
	if (Simulation.isInMouseFunctionMode)
	{
		//Uncomment this to have the cursor show when it hovers the GUI in mouse function mode
		if (io.WantCaptureMouse)
		{
			glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
			return; // If ImGui is capturing the mouse, do not process further
		}
		else
		{
			glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
		}
		
	}
	
	float sensitivityMultiplier = 1.2; // Sensitivity multiplier for mouse movement
	MouseX = ( 2.0*x/XWindowSize - 1.0)*RadiusOfLeftAtrium *sensitivityMultiplier;
	MouseY = (-2.0*y/YWindowSize + 1.0)*RadiusOfLeftAtrium *sensitivityMultiplier;
}

/*
 This function does an action based on the mode the viewer is in and which mouse button the user pressed.
*/
void myMouseCallback(GLFWwindow* window, int button, int action, int mods)
{	
	// Add this if we want the GUI to only accept GUI handling until you ckick off of it
	// Get ImGui IO to check if it's capturing input
	ImGuiIO& io = ImGui::GetIO();
    
	// If ImGui is handling this mouse event, return
	if (io.WantCaptureMouse) return;
	
	if(action == GLFW_PRESS)
	{
		float3 mousePos = {(float)MouseX, (float)MouseY, (float)MouseZ};
		if(button == GLFW_MOUSE_BUTTON_LEFT)
		{	
			if(Simulation.mouseMode == MouseModePulseNode)
			{
				int nodeId = findClosestNodeToMouse(mousePos);
				if(nodeId != -1)
				{
					PulsePointNode = nodeId;
				}
			}
			else if(Simulation.mouseMode == MouseModeBackTop)
			{
				int nodeId = findClosestNodeToMouse(mousePos);
				if(nodeId != -1)
				{
					ReferencePointNode = nodeId;
					setReferencePoints();
				}
			}
			else
			{
				assignNodes(mousePos, Simulation.mouseMode);
			}
		}
		else if(button == GLFW_MOUSE_BUTTON_RIGHT) // Right Mouse button down
		{
			assignNodes(mousePos, NodeTypeStandardLA);
		}
		else if(button == GLFW_MOUSE_BUTTON_MIDDLE)
		{
			if(ScrollSpeedToggle == 0)
			{
				ScrollSpeedToggle = 1;
				ScrollSpeed = ScrollSpeedFast;
			}
			else
			{
				ScrollSpeedToggle = 0;
				ScrollSpeed = ScrollSpeedSlow;
			}
			
		}
	}
}

void scrollWheelCallback(GLFWwindow* window, double xoffset, double yoffset)
{
	bool ctrlHeld = (glfwGetKey(window, GLFW_KEY_LEFT_CONTROL) == GLFW_PRESS || glfwGetKey(window, GLFW_KEY_RIGHT_CONTROL) == GLFW_PRESS);

	// Ctrl + scroll adjusts selector size to match model-side workflow.
	if(ctrlHeld)
	{
		if(yoffset > 0)
		{
			MouseSelectionRadiusMultiplier += 0.025f;
			if(MouseSelectionRadiusMultiplier > 0.5f) MouseSelectionRadiusMultiplier = 0.5f;
		}
		else if(yoffset < 0)
		{
			MouseSelectionRadiusMultiplier -= 0.01f;
			if(MouseSelectionRadiusMultiplier < 0.01f) MouseSelectionRadiusMultiplier = 0.01f;
		}
	}
	else
	{
		if(yoffset > 0) // Scroll up
		{
			MouseZ -= ScrollSpeed;
		}
		else if(yoffset < 0) // Scroll down
		{
			MouseZ += ScrollSpeed;
		}
	}
}

//******************* Graphical User Interface Functions ***********************************************

/*
 This function:
 Adds a comment below whatever button it is placed below. The format is below.
 ShowTooltip("Bla Bla");
*/
static inline void ShowTooltip(const char* text)
{
	if (ImGui::IsItemHovered())
	{
		ImGui::BeginTooltip();
		ImGui::TextUnformatted(text);
		ImGui::EndTooltip();
	}
}

void createGUI()
{
	// Get actual viewport size -- this is the size of the window, not the size of the the openGL viewport
	const ImGuiViewport* viewport = ImGui::GetMainViewport();

	//status panel: always visible so the user knows whether simulation is in GUI mode or mouse mode.
	ImGui::SetNextWindowPos(ImVec2(viewport->WorkPos.x + 10, viewport->WorkPos.y + 10), ImGuiCond_Always, ImVec2(0.0f, 0.0f));
	ImGuiWindowFlags status_flags = ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoSavedSettings;
	
	// Sub Gui window (Top left)
	ImGui::Begin("Interaction Mode", NULL, status_flags);
		if (!Simulation.isInMouseFunctionMode)
		{
			ImGui::TextColored(ImVec4(0.2f, 0.9f, 0.2f, 1.0f), "GUI Mode");
			ImGui::TextUnformatted("Mouse editing disabled");
		}
		else
		{
			ImGui::TextColored(ImVec4(1.0f, 0.75f, 0.2f, 1.0f), "Mouse Mode");
			     if (Simulation.mouseMode == MouseModeStandardLA) ImGui::TextUnformatted("Select: StandardLA");
			else if (Simulation.mouseMode == MouseModeBachmannsBundle) ImGui::TextUnformatted("Select: Bachmann's Bundle");
			else if (Simulation.mouseMode == MouseModeAppendage) ImGui::TextUnformatted("Select: LA Appendage");
			else if (Simulation.mouseMode == MouseModeScarTissue) ImGui::TextUnformatted("Select: Scar Tissue");
			else if (Simulation.mouseMode == MouseModePulmonaryVeins) ImGui::TextUnformatted("Select: Pulmonary Veins");
			else if (Simulation.mouseMode == MouseModeMitralValve) ImGui::TextUnformatted("Select: Mitral Valve");
			else if (Simulation.mouseMode == MouseModePulseNode) ImGui::TextUnformatted("Select: Pulse Node");
			else if (Simulation.mouseMode == MouseModeBackTop) ImGui::TextUnformatted("Select: Reference Nodes");
			else ImGui::TextUnformatted("Section: None");
		}
		ImGui::TextUnformatted("Tab: Toggle GUI/Mouse mode");
		if (SubGUIMessage[0] != '\0')
		{
			ImGui::Separator();
			ImGui::TextWrapped("%s", SubGUIMessage);
		}
	ImGui::End();

	// Mouse mode hides the control panel to match model behavior.
	if(Simulation.isInMouseFunctionMode == true)
	{
		return;
	}

	//Set in top right corner of the window, 10px offset from both edges
	//ImGUICond_Always means the position will always be set to this value, regardless of previous positions
	//last arg anchors to the right and top of the window
	ImGui::SetNextWindowPos(ImVec2(viewport->WorkPos.x + viewport->WorkSize.x - 10, viewport->WorkPos.y + 10), ImGuiCond_Always,  ImVec2(1.0f, 0.0f));

	// Setup ImGui window flags
	ImGuiWindowFlags window_flags = 0; // Initialize window flags to 0, flags are used to set window properties, like size, position, etc. 0 means no flags are set
	window_flags = ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoFocusOnAppearing; // Always resize the window to fit the content
    

	// Set the collapsed state if guiCollapsed is true (toggled by ctrl + h callback)
	ImGui::SetNextWindowCollapsed(Simulation.guiCollapsed, ImGuiCond_Always);


	// Main Controls Window
	ImGui::Begin("Control Panel", NULL, window_flags); //title of the window, NULL means no pointer to a bool to close the window, window_flags are the flags we set above
	    
		//update bool to match current state (makes sure clicking also works in addition to ctrl + h)
		Simulation.guiCollapsed = ImGui::IsWindowCollapsed();
	    
		// General simulation controls
		if (ImGui::CollapsingHeader("Simulation Controls", ImGuiTreeNodeFlags_DefaultOpen)) //open by default
		{
			// View controls
			bool frontHalf = Simulation.DrawFrontHalfFlag == 1; //Needed because ImGui needs a bool for a checkbox, can make a dropbox if more display options are needed
			if(ImGui::Checkbox("Draw Front Half Only", &frontHalf)) //checkbox for if we only want to draw the first half of the nodes
			{
				//when the button is pressed it will change the value of frontHalf to the opposite of what it was before
				Simulation.DrawFrontHalfFlag = frontHalf ? 1 : 0;
			}
		
			// Node display options
			const char* nodeOptions[] = { "Off", "Half", "Full" }; //array of options for the dropdown menu
			int nodeDisplay = Simulation.DrawNodesFlag;

			//Combo makes a dropdown menu with the options in the array
			if(ImGui::Combo("Show Nodes", &nodeDisplay, nodeOptions, 3)) //args are menu name, pointer to the selected option, array of text options, # of options
			{
				if (nodeDisplay != Simulation.DrawNodesFlag) // Only update if the value changes
				{
					Simulation.DrawNodesFlag = nodeDisplay;
				}
			}
		}       
	       
		// View presets
		if (ImGui::CollapsingHeader("View Controls", ImGuiTreeNodeFlags_DefaultOpen))//2nd arg is the flags, DefaultOpen means it will be open by default
		{
			if (ImGui::Button("PA"))
			{ 
				setView(4); 
			}
			
			ImGui::SameLine();
			if (ImGui::Button("AP"))  
			{
				setView(2); 
			}
			
			ImGui::SameLine();
			if (ImGui::Button("Ref"))
			{ 
				setView(6);  
			}
			
			if (ImGui::Button("LAO"))
			{ 
				setView(1);   
			}
			
			ImGui::SameLine();
			if (ImGui::Button("RAO"))
			{ 
				setView(3); 
			}
			
			ImGui::SameLine();
			if (ImGui::Button("LL"))
			{ 
				setView(7);  
			}

			if (ImGui::Button("RL"))
			{ 
				setView(9); 
			}
			
			ImGui::SameLine();
			if (ImGui::Button("SUP"))
			{ 
				setView(8);  
			}
			
			ImGui::SameLine();
			if (ImGui::Button("INF"))
			{ 
				setView(5);  
			}
		}
		
		// Mouse mode selection
		if (ImGui::CollapsingHeader("Mouse Functions", ImGuiTreeNodeFlags_DefaultOpen))
		{
			// Mouse mode buttons
			MouseX = 0.0; // Centering the mouse sphere.
			MouseY = 0.0;
			
			if (ImGui::Button("Set Pulse Node")) 
			{
				Simulation.mouseMode = MouseModePulseNode;
				Simulation.isInMouseFunctionMode = true;
				Simulation.guiCollapsed = true;
				glfwSetCursorPos(Window, XWindowSize/2.0, YWindowSize/2.0); // Setting the cursor to the center.
			}
			ShowTooltip("Sets the pulse node.");
			
			if (ImGui::Button("Set Reference point & Nodes")) 
			{
				Simulation.mouseMode = MouseModeBackTop;
				Simulation.isInMouseFunctionMode = true;
				Simulation.guiCollapsed = true;
				glfwSetCursorPos(Window, XWindowSize/2.0, YWindowSize/2.0); // Setting the cursor to the center.
			}

			if (ImGui::Button("Set Standard LA Node")) 
			{
				Simulation.mouseMode = NodeTypeStandardLA;
				Simulation.isInMouseFunctionMode = true;
				Simulation.guiCollapsed = true;
				glfwSetCursorPos(Window, XWindowSize/2.0, YWindowSize/2.0); // Setting the cursor to the center.
			}

			if (ImGui::Button("Set Bachmann's Bundle")) 
			{
				Simulation.mouseMode = MouseModeBachmannsBundle;
				Simulation.isInMouseFunctionMode = true;
				Simulation.guiCollapsed = true;
				glfwSetCursorPos(Window, XWindowSize/2.0, YWindowSize/2.0); // Setting the cursor to the center.
			}
			
			if (ImGui::Button("Set Appendage")) 
			{
				Simulation.mouseMode = MouseModeAppendage;
				Simulation.isInMouseFunctionMode = true;
				Simulation.guiCollapsed = true;
				glfwSetCursorPos(Window, XWindowSize/2.0, YWindowSize/2.0); // Setting the cursor to the center.
			}
			
			if (ImGui::Button("Set Scar Tissue")) 
			{
				Simulation.mouseMode = MouseModeScarTissue;
				Simulation.isInMouseFunctionMode = true;
				Simulation.guiCollapsed = true;
				glfwSetCursorPos(Window, XWindowSize/2.0, YWindowSize/2.0); // Setting the cursor to the center.
			}

			if (ImGui::Button("Set Pulmonary Veins")) 
			{
				Simulation.mouseMode = MouseModePulmonaryVeins;
				Simulation.isInMouseFunctionMode = true;
				Simulation.guiCollapsed = true;
				glfwSetCursorPos(Window, XWindowSize/2.0, YWindowSize/2.0); // Setting the cursor to the center.
			}

			if (ImGui::Button("Set Mitral Valve")) 
			{
				Simulation.mouseMode = MouseModeMitralValve;
				Simulation.isInMouseFunctionMode = true;
				Simulation.guiCollapsed = true;
				glfwSetCursorPos(Window, XWindowSize/2.0, YWindowSize/2.0); // Setting the cursor to the center.
			}
			
			if (ImGui::Button("Set Back Wall")) 
			{
				Simulation.mouseMode = MouseModeBackWall;
				Simulation.isInMouseFunctionMode = true;
				Simulation.guiCollapsed = true;
				glfwSetCursorPos(Window, XWindowSize/2.0, YWindowSize/2.0); // Setting the cursor to the center.
			}
			
			if (ImGui::Button("Set Extra Tissue")) 
			{
				Simulation.mouseMode = MouseModeExtraTissue;
				Simulation.isInMouseFunctionMode = true;
				Simulation.guiCollapsed = true;
				glfwSetCursorPos(Window, XWindowSize/2.0, YWindowSize/2.0); // Setting the cursor to the center.
			}

		}
	    
		// Utility functions
		if (ImGui::CollapsingHeader("Utilities", ImGuiTreeNodeFlags_DefaultOpen))
		{
			if (ImGui::Button("Save Binary"))
			{
				saveBinary();
			}
			if (ImGui::Button("Screenshot"))
			{
				screenShot();
			}
		}

		//Display movement controls
		if (ImGui::CollapsingHeader("Keyboard Controls"))
		{
			ImGui::Text("Quit: esc");
			ImGui::NewLine(); //added a new line for spacing
			ImGui::Text("Translate Left/Right: x/X");
			ImGui::Text("Translate Up/Down:    y/Y");
			ImGui::Text("Translate In/Out:     z/Z");
			ImGui::NewLine(); //added a new line for spacing
			ImGui::Text("Rotate X-axis: Ctrl x/X");
			ImGui::Text("Rotate Y-axis: Ctrl y/Y");
			ImGui::Text("Rotate Z-axis: Ctrl z/Z");
			ImGui::NewLine(); //added a new line for spacing
			ImGui::Text("Selection Sphere Size Adjustment: +/-");
			ImGui::NewLine(); //added a new line for spacing
			ImGui::Text("Toggle GUI/Mouse mode: Tab");			
		}
	ImGui::End(); //end the main controls window
  
}

//******************* Utility Functions ********************************************
/*
 This function:
 Simple finds the center of the object and returns it.
*/
float4 findCenterOfObject()
{
	float4 centerOfObject;
	
	centerOfObject.x = 0.0;
	centerOfObject.y = 0.0;
	centerOfObject.z = 0.0;
	centerOfObject.w = 0.0;
	for(int i = 0; i < NumberOfNodes; i++)
	{
		 centerOfObject.x += Node[i].position.x;
		 centerOfObject.y += Node[i].position.y;
		 centerOfObject.z += Node[i].position.z;
		 centerOfObject.w += 1.0;;
	}
	if(centerOfObject.w < 1.0)
	{
		printf("\n There seems to be no nodes.");
		printf("\n The simulation has been terminated to stop divition by zero.\n");
		exit(0);
	}
	else
	{
		centerOfObject.x /= centerOfObject.w;
		centerOfObject.y /= centerOfObject.w;
		centerOfObject.z /= centerOfObject.w;
	}
	return(centerOfObject);
}

/*
 This function: 
 Centers the LA and resets the center of view to (0, 0, 0).
 It is called periodically in a running simulation to center the LA, because the LA is not symmetrical 
 and will wander off over time. It is also use to center the LA before all the views are set.
*/
void centerObject()
{
	float4 centerOfObject = findCenterOfObject();
	for(int i = 0; i < NumberOfNodes; i++)
	{
		Node[i].position.x -= centerOfObject.x;
		Node[i].position.y -= centerOfObject.y;
		Node[i].position.z -= centerOfObject.z;
	}
	
	CenterOfSimulation.x = 0.0;
	CenterOfSimulation.y = 0.0;
	CenterOfSimulation.z = 0.0;
}

/* 
 This function:
 Physicaly otates the object. It takes the angle then looks to see which axis is not zero and it rotates around those axises.
 You could use glRotate and this would change your view but your x,y,z locations do not get ajdusted and where we put the 
 selection sphere when selecting nodes get all screwed up so we most move all the nodes not the view.
 This is the view rotate function for reference glRotatef(dAngle, 0.0f, 0.0f, 1.0f);
*/	
void rotateObject(float angle, int xAxis, int yAxis, int zAxis)
{
	for(int i = 0; i < NumberOfNodes; i++)
	{
		Node[i].position.x -= CenterOfSimulation.x;
		Node[i].position.y -= CenterOfSimulation.y;
		Node[i].position.z -= CenterOfSimulation.z;
	}
	
	float temp;
	if(xAxis != 0)
	{
		for(int i = 0; i < NumberOfNodes; i++)
		{
			temp = cos(angle)*Node[i].position.y - sin(angle)*Node[i].position.z;
			Node[i].position.z  = sin(angle)*Node[i].position.y + cos(angle)*Node[i].position.z;
			Node[i].position.y  = temp;
		}
		AngleOfSimulation.x += angle;
	}
	if(yAxis != 0)
	{
		for(int i = 0; i < NumberOfNodes; i++)
		{
			temp =  cos(-angle)*Node[i].position.x + sin(-angle)*Node[i].position.z;
			Node[i].position.z  = -sin(-angle)*Node[i].position.x + cos(-angle)*Node[i].position.z;
			Node[i].position.x  = temp;
		}
		AngleOfSimulation.y += angle;
	}
	if(zAxis != 0)
	{
		for(int i = 0; i < NumberOfNodes; i++)
		{
			temp = cos(angle)*Node[i].position.x - sin(angle)*Node[i].position.y;
			Node[i].position.y  = sin(angle)*Node[i].position.x + cos(angle)*Node[i].position.y;
			Node[i].position.x  = temp;
		}
		AngleOfSimulation.z += angle;
	}
	
	for(int i = 0; i < NumberOfNodes; i++)
	{
		Node[i].position.x += CenterOfSimulation.x;
		Node[i].position.y += CenterOfSimulation.y;
		Node[i].position.z += CenterOfSimulation.z;
	}
}

/* 
 This function:
 Translates the object by dx. dy, and dz.
 You could use glTranslatef and this would change your view but your x,y,z locations do not get ajdusted and where we put the 
 selection sphere when selecting nodes get all screwed up so we must move all the nodes not the view.
 This is the view translate function for reference glTranslatef(dx, dy, dz);
*/
void translateObject(float dx, float dy, float dz)
{
	for(int i = 0; i < NumberOfNodes; i++)
	{
		Node[i].position.x += dx;
		Node[i].position.y += dy;
		Node[i].position.z += dz;
	}
	
	CenterOfSimulation.x += dx;
	CenterOfSimulation.y += dy;
	CenterOfSimulation.z += dz;
}

/*
 This function:
 Sets a single muscle type and color based on its endpoint node types.
*/
void setSingleMuscleTypeAndColor(int muscleId)
{
	int a = Muscle[muscleId].nodeA;
	int b = Muscle[muscleId].nodeB;

	int typeA = Node[a].type;
	int typeB = Node[b].type;
	if(typeA == typeB) Muscle[muscleId].type = typeA;
	else
	{
		int priorityA = getTypePriority(typeA);
		int priorityB = getTypePriority(typeB);
		if(priorityA < priorityB) 
		{
			Muscle[muscleId].type = typeA;
			Muscle[muscleId].color = getColorFromType(typeA);
		}
		else 
		{
			Muscle[muscleId].type = typeB;
			Muscle[muscleId].color = getColorFromType(typeB);
		}
	}
}

/*
 This function: 
 Sets all muscle types and colors.
*/
void setAllMuscleTypesAndColors()
{
	for(int i = 0; i < NumberOfMuscles; i++)
	{
		setSingleMuscleTypeAndColor(i);
	}
}

/*
 This function:
 Checks to see if a node is within a hit radius of the mouse.
*/
bool isNodeInMouseSphere(int nodeId, float3 mousePos) 
{
	float dx, dy,dz, d2, hit2;
	hit2 = MouseSelectionRadiusMultiplier * MouseSelectionRadiusMultiplier * RadiusOfLeftAtrium * RadiusOfLeftAtrium;
	dx = Node[nodeId].position.x - mousePos.x;
	dy = Node[nodeId].position.y - mousePos.y; 
	dz = Node[nodeId].position.z - mousePos.z; 
	d2 = dx*dx + dy*dy + dz*dz;
	if(d2 < hit2) return true;
	else return false;
}

/*
 This function:
 Returns the closest node to the mouse cursor but it must also be within a hit radius of the mouse.
*/
int findClosestNodeToMouse(float3 mousePos)
{
	int closestNode = -1;
	float closestDistSquared = FLOATMAX;
	float hitRadiusSquared = MouseSelectionRadiusMultiplier * MouseSelectionRadiusMultiplier * RadiusOfLeftAtrium * RadiusOfLeftAtrium;

	for(int i = 0; i < NumberOfNodes; i++)
	{
		float dx = Node[i].position.x - mousePos.x;
		float dy = Node[i].position.y - mousePos.y;
		float dz = Node[i].position.z - mousePos.z;
		float distSquared = dx*dx + dy*dy + dz*dz;
		if(distSquared < hitRadiusSquared && distSquared < closestDistSquared)
		{
			closestDistSquared = distSquared;
			closestNode = i;
		}
	}
	return closestNode;
}

/*
 This function:
 Returns priority for a node type when resolving mixed-type muscles.
 Returns -1 for unknown types.
 Put an integer behind each type with smallest number being the most important
 and largest being the least important. If you need to add a new type just place it in
 the list and arange the priority.
*/
int getTypePriority(int type)
{
	if(type == NodeTypeStandardLA) return 7;
	if(type == NodeTypeBachmannBundle) return 1;
	if(type == NodeTypeAppendage) return 3;
	if(type == NodeTypeScarTissue) return 6;
	if(type == NodeTypePulmonaryVeins) return 2;
	if(type == NodeTypeMitralValve) return 4;
	if(type == NodeTypeBackWall) return 5;
	if(type == NodeTypeExtraTissue) return 8;
	else
	{
		printf("\n Error: Unknown node type while setting type priority.");
		printf("\n Simulation has been terminated.\n");
		exit(0);
	}
}

/*
 This function:
 Returns the color for given type.
*/
float4 getColorFromType(int type)
{	
	if(type == NodeTypeStandardLA) return ColorStandardLA;
	if(type == NodeTypeBachmannBundle) return ColorBachmannsBundle;
	if(type == NodeTypeAppendage) return ColorAppendage;
	if(type == NodeTypeScarTissue) return ColorScarTissue;
	if(type == NodeTypePulmonaryVeins) return ColorPulmonaryVeins;
	if(type == NodeTypeMitralValve) return ColorMitralValve;
	if(type == NodeTypeBackWall) return ColorBackWall;
	if(type == NodeTypeExtraTissue) return ColorExtraTissue;
	else
	{
		printf("\n Error: Unknown node type while setting type colors.");
		printf("\n Simulation has been terminated.\n");
		exit(0);
	}
}

/*
 This function returns a timestamp in M-D-Y-H.M.S format.
 This is use so each file that is created has a unique name. 
 Note: You cannot create more than one file in a second or you will over write the previous file.
*/
const char *getTimeStamp(void)
{
    static char timestamp[64];
    time_t t = time(NULL);
    struct tm *now = localtime(&t);

    if (now == NULL) return "";
    snprintf(timestamp, sizeof(timestamp),
             "%d-%d-%d_%d.%02d.%02d",
             now->tm_mon + 1,
             now->tm_mday,
             now->tm_year + 1900,
             now->tm_hour,
             now->tm_min,
             now->tm_sec);
    return timestamp;
}

/*
 This function:
 Frees memory and shuts everything dowm.
*/
void shutdownAndCleanup()
{
	//delete the state file if it exists.
	remove("simulation_state.bin");
	
	// Free memory
	free(Muscle);
	free(Node);
	
	//shutdown ImGui
	ImGui_ImplOpenGL3_Shutdown();
	ImGui_ImplGlfw_Shutdown();
	ImGui::DestroyContext();

	//destroy the window and terminate GLFW
	glfwDestroyWindow(Window);
  	glfwTerminate();
}

