model TangibleUrbanSwarm

global skills:[network]{
	// Global variables
	int number_of_epucks;
	int first_robot_id <- 20;

	// Recording-related variables
	bool recording_experiment;

	// Viz layer variables
	bool show_robot;
	float robot_size;
	bool draw_IR;
	bool draw_robot_name;
	bool draw_trajectory;
	bool draw_battery_level;
	bool draw_completed_merkle_leafs;
	file low_battery_icon <- file('./../images/low_battery_icon.png');
	int trajectory_length;
	float trajectory_alpha;
	float trajectory_refresh_rate<-1;

	// Graph-related variables
	bool drawProximityGraph;
	int proximity_graph_distance;
	graph<epuck, epuck> proximity_graph;
	bool drawConnectivityGraph;
	graph connectivity_graph <- graph([]);
	string drawConnectivityConnector;
	
	bool drawMerkleExchangeGraph;
	graph merkle_exchange_graph <- graph([]);
	
	bool drawMerkleQueryGraph;
	graph merkle_query_graph <- graph([]);

	// Arena-related variables
	geometry shape<-rectangle(250,250);
	point arena_center <- {shape.width/2, shape.height/2};
	container arena_keystone <- [{-0.022823418770420267,-0.006048894177093644,0.0},{-0.03450525124742615,0.9936260704298561,0.0},{1.0198878722143023,1.0050958669343275,0.0},{1.0148650696582069,0.019365296959545808,0.0}];
	
	// Foraging color-related variables
	bool DrawExtendedInfo;
	bool GenerateRandomColors <- true;
	int NumberOfCellsWithSameColor <- 1;
	int number_of_colors <- 0;
		
	rgb cell_black <- rgb(20,0,20);
	rgb cell_magenta <- rgb(160,60,120);
	rgb cell_orange <- rgb(255, 120, 20);
	rgb cell_yellow <- rgb(255,215,0);
	rgb	cell_green <- rgb(0,110,0);
	rgb cell_blue <- rgb(2,51, 255);
	rgb cell_cyan <- rgb(0,253,255);
	rgb cell_white <- rgb(190,190,190);
	rgb cell_grey <- rgb(120,80,80);
	rgb cell_red <- rgb(255, 50, 10);
	rgb cell_lime <-rgb(2, 255, 50);
	
	list cell_colors <- [cell_green, cell_magenta, cell_blue, cell_yellow, cell_red, cell_cyan, cell_lime, cell_orange];
	list cell_colors_string <- ['green', 'magenta', 'blue', 'yellow', 'red', 'cyan', 'lime', 'orange'];
	rgb color_calibration <- cell_black;
	
	list<point> colored_cells;
	matrix<rgb> color_matrix <- {5,5} matrix_with(cell_black);
	matrix<string> color_matrix_string <- {color_matrix.rows,color_matrix.columns} matrix_with('black');
	
	// MK colors
	rgb good_blue <- rgb(50, 150, 255, 225);
	rgb area_blue <- rgb(25, 90, 255, 255);
	rgb good_red <- rgb(255,100,50,255);
	rgb good_green <- rgb(0,255,0,255);
	
	// Create the robots' instances together with a UDP server 
	init {
		int i <- 0;
		create epuck number:number_of_epucks {
		   do connect to: "localhost" protocol: "udp_server" port: 9800+first_robot_id+i;
		   i<-i+1;
		}
		
    	do connect to:"localhost" protocol: "udp_emitter" port: 9900;
	}

	reflex updateProximityGraph when:(drawProximityGraph) {
		proximity_graph <- graph<epuck, epuck>(epuck as_distance_graph(proximity_graph_distance));
	}

	reflex send {
		do send contents: '{"cells": ' + reverse(color_matrix_string) collect (each) + '}';
	}
}

grid arena cell_width:50 cell_height:50 {
	
	// Display the arena without the cell border lines to not interfere with the tracking system
	aspect color_calibration{
		draw shape color:#black border:#transparent width:5;	
				
		// draw all the cells 		
		loop index_row from: 0 to: color_matrix.rows - 1 {
			loop index_column from: 0 to: color_matrix.columns - 1 {
				draw arena[index_row,index_column] color:color_calibration border:#transparent width:5;
			}
		} 
	}
		
	// Display the arena with the cell border lines to be distinguisable in the PC screen
	aspect simulator{
		draw shape color:#black border:#black width:5;
		int arena_dimension <- int(sqrt(length(arena)));
		
		if(GenerateRandomColors and DrawExtendedInfo)
		{
			color_matrix <- process_color_matrix(arena_dimension, number_of_colors);
			GenerateRandomColors <- false;
		}
		
		// Draw all the resultant colors on the arena
		loop index_row from: 0 to: color_matrix.rows - 1 {
			loop index_column from: 0 to: color_matrix.columns - 1 {
				draw arena[index_row,index_column] color:color_matrix at {index_row,index_column} border:#white width:5;
			}
		}
		
		// Display sequence at the center based on the leaves discovered by the robots
		list<int> merkle_leafs_index;	
		ask epuck 
		{
			add self.number_of_completed_leafs to: merkle_leafs_index; 
		}
		
		int current_leaf <- max(merkle_leafs_index);	
		list<geometry> center_cell_rectangles;
	
		if (current_leaf = 1)
			{
				center_cell_rectangles <- to_rectangles(arena[2,2], 1, 1);
			}
		else if(current_leaf = 2)
			{
				center_cell_rectangles <- to_rectangles(arena[2,2], 1, 2);
			}
		else if(current_leaf = 3 or current_leaf = 4)
			{
				center_cell_rectangles <- to_rectangles(arena[2,2], 2, 2);	
			}		
		else if(current_leaf > 4)
			{
				center_cell_rectangles <- to_rectangles(arena[2,2], 2, 4);
			}
		
		int i <- 0;	
		if(current_leaf > 0)
		{	
			loop s from:0 to: current_leaf - 1 
			{	
				draw center_cell_rectangles[s] color: cell_colors[i] border:#transparent;
				i <- i + 1;
			}
		}
		
		// Draw the task IDs on top of each color cell
		if(DrawExtendedInfo){
			loop color over: cell_colors_string
			{
				loop index_row from: 0 to: color_matrix.rows - 1 {
					loop index_column from: 0 to: color_matrix.columns - 1 {
						if (color_matrix_string[index_row, index_column] = color)
						{
							draw ("TASK " + string(cell_colors_string index_of color)) color:cell_black at: {index_row*50 + 24, index_column*50 + 9, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
						}
					}
				}
			}
		}
	}
	
	// Display the arena without the cell border lines to not interfere with the tracking system
	aspect projector{
		draw shape color:#black border:#transparent width:5;	
		int arena_dimension <- int(sqrt(length(arena)));
		
		if(GenerateRandomColors and DrawExtendedInfo)
		{
			color_matrix <- process_color_matrix_predefined(arena_dimension, number_of_colors);
			GenerateRandomColors <- false;
		}
							
		// Draw all the resultant colors on the arena		
		loop index_row from: 0 to: color_matrix.rows - 1 {
			loop index_column from: 0 to: color_matrix.columns - 1 {
				draw arena[index_row,index_column] color:color_matrix at {index_row,index_column} border:#transparent width:5;
			}
		}
		
		// Display sequence at the center based on the leaves discovered by the robots
		list<int> merkle_leafs_index;	
		ask epuck 
		{
			add self.number_of_completed_leafs to: merkle_leafs_index; 
		}
		
		int current_leaf <- max(merkle_leafs_index);
		list<geometry> center_cell_rectangles;
	
		if (current_leaf = 1)
			{
				center_cell_rectangles <- to_rectangles(arena[2,2], 1, 1);
			}
		else if(current_leaf = 2)
			{
				center_cell_rectangles <- to_rectangles(arena[2,2], 1, 2);
			}
		else if(current_leaf = 3 or current_leaf = 4)
			{
				center_cell_rectangles <- to_rectangles(arena[2,2], 2, 2);	
			}		
		else if(current_leaf > 4)
			{
				center_cell_rectangles <- to_rectangles(arena[2,2], 2, 4);
			}
		
		int i <- 0;	
		if(current_leaf > 0)
		{	
			color_matrix_string[round((arena_dimension-1)/2), round((arena_dimension-1)/2)] <- copy_between(cell_colors_string,0,current_leaf);
			
			loop s from:0 to: current_leaf - 1 
			{	
				draw center_cell_rectangles[s] color: cell_colors[i] border:#transparent;
				i <- i + 1;
				
				if(DrawExtendedInfo)
				{	if (center_cell_rectangles[s].location.x > 125)
					{
						draw ("T " + string(i)) color:#white at: {center_cell_rectangles[s].location.x + 15, center_cell_rectangles[s].location.y - 5, 0.001} font:font("Helvetica", 30 , #plain) bitmap:false rotate: 90;
					}
					else
					{
						draw ("T " + string(i)) color:#white at: {center_cell_rectangles[s].location.x - 20, center_cell_rectangles[s].location.y - 5, 0.001} font:font("Helvetica", 30 , #plain) bitmap:false rotate: 90;
					}	
				}
				
			}
		}
		else
		{
			color_matrix_string	[round((arena_dimension-1)/2), round((arena_dimension-1)/2)] <- [];
		}
				
		// Draw the task IDs on top of each color cell
		if(DrawExtendedInfo and time > 250){
			loop color over: cell_colors_string
			{
				loop index_row from: 0 to: color_matrix.rows - 1 {
					loop index_column from: 0 to: color_matrix.columns - 1 {
						if (color_matrix_string[index_row, index_column] = color)
						{
							draw ("TASK " + string(cell_colors_string index_of color + 1)) color:#white at: {index_row*50 + 24, index_column*50 + 9, 0.5} font:font("Helvetica", 40 , #plain) bitmap:false rotate: 90;
						}
					}
				}
			}
		}
	}
		
	aspect initialization_state{		
		if(DrawExtendedInfo){
			// Display the arena without the cell border lines to not interfere with the tracking system
			draw shape color:#black border:#transparent width:5;	
			// draw init circle at the center
	    	draw circle(30) color:#white at:{125,125};				
		}
	}
	// Color randomization of the arena space	
	matrix process_color_matrix(int arena_dimension, int num_of_colors)
	{ 	
		if(num_of_colors > 0)
		{	 		
	            loop x from: 0 to: num_of_colors - 1
	            {
					loop y from: 0 to: NumberOfCellsWithSameColor - 1
					{	
						int rand_x <- rnd(arena_dimension - 1);
						int rand_y <- rnd(arena_dimension - 1);
								
						loop while: (colored_cells contains {rand_x,rand_y} or {rand_x, rand_y} = {round((arena_dimension-1)/2),round((arena_dimension-1)/2)})
						{
							rand_x <- rnd(arena_dimension - 1);
							rand_y <- rnd(arena_dimension - 1);		
						}
						
						color_matrix[rand_x, rand_y] <- cell_colors[x];
						color_matrix_string[rand_x, rand_y] <- cell_colors_string[x];
						add {rand_x, rand_y} to: colored_cells;	
					}
				}
		}		
	   	return color_matrix; 
	}
	
	// Color randomization of the arena space	
	matrix process_color_matrix_predefined(int arena_dimension, int num_of_colors)
	{		
		color_matrix[2, 0] <- cell_colors[0];
		color_matrix_string[2, 0] <- cell_colors_string[0];
		
		color_matrix[3, 4] <- cell_colors[1];
		color_matrix_string[3, 4] <- cell_colors_string[1];
		
		color_matrix[4, 2] <- cell_colors[2];
		color_matrix_string[4, 2] <- cell_colors_string[2];
		
		color_matrix[3, 0] <- cell_colors[3];
		color_matrix_string[3, 0] <- cell_colors_string[3];
		
		color_matrix[1, 4] <- cell_colors[4];
		color_matrix_string[1, 4] <- cell_colors_string[4];
		
		color_matrix[0, 1] <- cell_colors[5];
		color_matrix_string[0, 1] <- cell_colors_string[5];
		
		color_matrix[0, 2] <- cell_colors[6];
		color_matrix_string[0, 2] <- cell_colors_string[6];
		
		color_matrix[4, 3] <- cell_colors[7];
		color_matrix_string[4, 3] <- cell_colors_string[7];
		
		return color_matrix;	
	}
}

species epuck skills:[network, moving] {

	// epuck name string
	string epuck_name;

	// Sensor-related variables
	list<float> ir;

	// Battery level variable (right now only boolean info)
	float battery_level;
	
	// Base leds variable
	bool base_leds;

	// Location and trajectory variables
	list<point> current_trajectory;
	
	// Merkle tree realated variables
	matrix<int> completed_merkle_matrix <- {3, 16} matrix_with 0; 
	int last_leaf_displayed <- 0;
	int number_of_completed_leafs <- 0;
	bool first_time_to_display_leaf <- true;
	date time_to_display_leaf;
			
	// Neighbor-related variables
	list<int> neighbors_ids;
	list<float> neighbors_ranges;

	reflex fetch when:has_more_message() {
		
		loop while:has_more_message()
		{
			message s <- fetch_message();

			// De-encapsulation of the UDP packet received
			list packet <- string(s.contents) split_with(";");
			// name of the robot
			epuck_name <- packet[0];
			
			// location and orientation of robot in 2D
			float y <- (float(packet[1])*100);
			float x <- (float(packet[2])*100);	
			float z <-(-float(packet[3])+90);	
			location <- tracking_system_correction(x,y);
			heading <- z;
			
			// Information from robot controller
			// exception handling in case robot controller 
			// doesn't send anything
			try
			{
				// proximity sensors
				ir <- [float(packet[4]),
					   float(packet[5]),
					   float(packet[6]),
					   float(packet[7]),
					   float(packet[8]),
					   float(packet[9]),
					   float(packet[10]),
					   float(packet[11])
				];
				
				// battery level
				battery_level <- float(packet[12]);
				// base_leds
				base_leds <- bool(packet[13]);
				
				// neighbor data
				neighbors_ids <- [];
				neighbors_ranges <- [];
				int number_of_neighbors <- int(packet[14]);
				if(number_of_neighbors > 0)
				{						
					loop x from: 0 to: number_of_neighbors - 1
					{     list neighbor_data <- packet[15+x] split_with(",");
						  int neighbor_id <- int(neighbor_data[0]);
						  float neighbor_range <- float(neighbor_data[1]);
					 	  add neighbor_id to: neighbors_ids;
					 	  add neighbor_range to: neighbors_ranges;
					}
				}
				
				// completed merkle tree data
				int starting_id_for_merkle_tree <- 16+number_of_neighbors;
				int number_of_leafs <- int(packet[starting_id_for_merkle_tree]);
				put 0 in: completed_merkle_matrix all: true;
				
				loop x from: 0 to: completed_merkle_matrix.rows - 1
				{	
					list leaf_data <- packet[starting_id_for_merkle_tree+x] split_with(",");				
					loop y from: 0 to: completed_merkle_matrix.columns - 1
					{	
						completed_merkle_matrix[{y,x}] <- int(leaf_data[y]);
					}
				}
			}
			catch
			{
					write string(epuck_name + " Is not sending controller data");
			}
		}
	}
	
	point tracking_system_correction(float x, float y){ 
			// Y axis correction
			y <- y + (y/250)*7;
			y <- y - (x/250)*7;
			// X axis correction
			x <- x + (y/250)*7;
			x <- x - (1 - (x/250))*5; 		
			// Move towards the center of the robot
			x <- x + 4;
			y <- y;
			
	   	return {x,y}; 
	}

	reflex updateConnectivityGraph when: (drawConnectivityGraph = true){
			connectivity_graph <- connectivity_graph add_node(self.location);
			loop id over: neighbors_ids
				{
					string neighbor_name <- 'epuck' + string(id - first_robot_id);
 					ask epuck where (each.name = neighbor_name)
					{
						connectivity_graph <- connectivity_graph add_node(self.location);
						connectivity_graph <- connectivity_graph add_edge(myself.location :: self.location);
					}
				}
	}

	reflex updateMerkleExchangeGraph when: (drawMerkleExchangeGraph = true and last_leaf_displayed < completed_merkle_matrix.rows){	
		loop leaf from: completed_merkle_matrix.rows - 1 to: last_leaf_displayed
			{				
				bool leaf_completed <- bool(completed_merkle_matrix[0,leaf]);	
				bool leaf_received <- bool(completed_merkle_matrix[1,leaf]);
				
				if (leaf_completed and not leaf_received)
				{
					highlight self color: good_red;
					break;
				}
				
				else if(leaf_completed and leaf_received)
				{								
					int leaf_sender_id <- int(completed_merkle_matrix[2,leaf]);
					string leaf_sender_name <- 'epuck' + string(leaf_sender_id - first_robot_id);
					
					ask epuck where (each.name = leaf_sender_name)
					{				
						merkle_exchange_graph <- merkle_exchange_graph add_node(myself.location);
						merkle_exchange_graph <- merkle_exchange_graph add_node(self.location);
						merkle_exchange_graph <- merkle_exchange_graph add_edge(self.location :: myself.location);	
					}
					
					if(first_time_to_display_leaf)
					{
						time_to_display_leaf <- #now;
						first_time_to_display_leaf <- false;
					}
					
					if (#now - time_to_display_leaf > 5)
					{ 
						last_leaf_displayed <- leaf + 1;
						first_time_to_display_leaf <- true;
					}
					
					break;
				}
			}
	}
	
	reflex updateMerkleQueryGraph when: (drawMerkleQueryGraph = true){	
		loop id over: neighbors_ids
				{
					string neighbor_name <- 'epuck' + string(id - first_robot_id);
 					ask epuck where (each.name = neighbor_name)
					{
						int my_number_of_completed_leafs <- columns_list(myself.completed_merkle_matrix)[0] count (each = 1);
						int neighbor_number_of_completed_leafs <- columns_list(self.completed_merkle_matrix)[0] count (each = 1);
						
						if(neighbor_number_of_completed_leafs > my_number_of_completed_leafs)
						{
								merkle_query_graph <- merkle_query_graph add_node(myself.location);
								merkle_query_graph <- merkle_query_graph add_node(self.location);
								merkle_query_graph <- merkle_query_graph add_edge(myself.location :: self.location);	
						}
					}
				}		
	}

	reflex calculateTrajectory when: (draw_trajectory = true) {
    	loop while:(length(current_trajectory) > trajectory_length){
	    		current_trajectory >> first(current_trajectory);
       		}
        	current_trajectory << location;
    }
    
    reflex calculateCompletedMerkleLeafs{
		number_of_completed_leafs <- columns_list(completed_merkle_matrix)[0] count (each = 1);
    }
    
	aspect default{

		// Robot shape
		if (show_robot){
			draw circle(robot_size) color: good_blue empty:true border: good_blue width:5 rotate:heading+90;
	    }

		// Robot name
		if (draw_robot_name){
			point vector <- {arena_center.x - location.x, arena_center.y - location.y};
			float length <- distance_to(arena_center, location);
			point gravity_vector <- {vector.x / length, vector.y / length}; 
			int distance_in_cms <- -20;
			string epuck_id <- 'R' + string(int(copy_between(epuck_name, 7, 9)) - first_robot_id + 1);
			draw (epuck_id) color:#white border:#white at:{(location.x-10) + gravity_vector.x * distance_in_cms, (location.y+5) + gravity_vector.y * distance_in_cms} font:font("SansSerif", 40 , #italic);
		}

		// Battery level
		if (draw_battery_level and time mod 10){
		  	if (int(battery_level) = 0){
		    	draw (low_battery_icon) size: {10,6} at: {location.x-12,location.y-12};
		 	}
		}

		// IR Sensors
		if(draw_IR){
	        // These represent the proximity sensors, this is what the robot uses in order to detect obstacles
	        // basically it should resemble this:
	        //             front(red)
	 		//
	 		//              0   7
	 		//     l     1         6    r
	 		//     e                    i
			//     f    2           5   g
			//     t                    h
			//             3     4      t
			//
			//              back

			// Padding between circle and sensors' position
			int padding <- 4;

			list<int> angles <- [20, 55, 90, 150, -150, -90, -55, -20];
			loop x from: 0 to: 7
			{
				rgb color_ir <- blend(good_blue, #white, ir[x]*12);
				draw rectangle(5,2) color: color_ir border: #black at:{location.x+((robot_size+padding)*cos(heading-angles[x])),location.y+((robot_size+padding)*sin(heading-angles[x]))} rotate:heading+(90-angles[x]);
			}
		}
		
		// Draw number with completed merkle tree leafs
		if(draw_completed_merkle_leafs){
			point vector <- {arena_center.x - location.x, arena_center.y - location.y};
			float length <- distance_to(arena_center, location);
			point gravity_vector <- {vector.x / length, vector.y / length}; 
			int distance_in_cms <- 12;
			draw string(number_of_completed_leafs) color:#white at:{location.x + gravity_vector.x * distance_in_cms, location.y + gravity_vector.y * distance_in_cms} rotate:90 font:font("SansSerif", 25 , #plain);
		}

		// Robot Tracjectory
		if(draw_trajectory){
			loop j from: 0 to: length(current_trajectory) {
				rgb color_trajectory <- blend(good_green, good_blue, j/length(current_trajectory));
			 	draw circle(robot_size) at_location current_trajectory[j] empty:true color: rgb(color_trajectory,trajectory_alpha);
		    }
		}
	}
}

experiment MainTangibleSwarmExperiment type: gui virtual: true {
	
	// Minimum cycle duration
	float minimum_cycle_duration<-0.04;
	
	// GENERAL PARAMETERS
	parameter "Number of epucks:" var: number_of_epucks <- 2 category: "General parameters" min: 0 max:100;
	parameter "Number of colors:" var:number_of_colors <- 8 category: "General parameters" min: 0 max:8;
	
	// EXPERIMENT PARAMETERS
	parameter "Capture:" var: recording_experiment <- false category: "Experiment Initialization";
	parameter "Display arena extended info:" var:DrawExtendedInfo <- false category: "Experiment Initialization";
	
	// VIZ PARAMETERS
    parameter "Show robot:" var: show_robot <- true  enables:[robot_size, draw_robot_name, draw_IR, drawProximityGraph, drawConnectivityGraph, draw_trajectory] category: "Viz Interaction";
    parameter "Robot size:" var: robot_size <- 5.0 min:1.0 max:10.0 category: "Viz Interaction";
    parameter "Draw robot name:" var: draw_robot_name <-false category: "Viz Interaction";
    parameter "Draw proximity sensors:" var: draw_IR <-false category: "Viz Interaction";
    parameter "Draw battery level:" var: draw_battery_level <-false category: "Viz Interaction";
	parameter "Draw proximity graph:" var:drawProximityGraph <- false enables:[proximity_graph_distance] category: "Connectivity Interaction";
	parameter "Proximity graph distance" var: proximity_graph_distance <- 100 category: "Connectivity Interaction" min: 1 max:150;
	parameter "Draw connectivity graph:" var:drawConnectivityGraph <- true enables:[drawConnectivityConnector] category: "Connectivity Interaction";
	parameter "Shape of connector:" var: drawConnectivityConnector <- "line" among: ["line", "curve"] category: "Connectivity Interaction";
	parameter "Draw merkle information:" var:draw_completed_merkle_leafs <- true enables:[drawMerkleExchangeGraph, drawMerkleQueryGraph] category: "Connectivity Interaction";
	parameter "Draw merkle exchage graph:" var:drawMerkleExchangeGraph <- true category: "Connectivity Interaction";
	parameter "Draw merkle query graph:" var:drawMerkleQueryGraph <- true category: "Connectivity Interaction";
	parameter "Trajectory:" category: "Viz Interaction" var:draw_trajectory <- false enables:[trajectory_length, trajectory_alpha];
	parameter "Trajectory Length:" category: "Viz Interaction" var:trajectory_length <- 50 min:0 max:100;
	parameter "Trajectory Transparency:" category: "Viz Interaction" var:trajectory_alpha <- 0.3 min:0.0 max:1.0;

	output {
		display objects_display type:opengl toolbar: false  rotate: 90 virtual:true {
			species epuck aspect: default;
	
				
			graphics "proximity_graph" {
				if(drawProximityGraph){
					loop eg over: proximity_graph.edges {
						geometry edge_geom <- geometry(eg);
						draw line(edge_geom.points) color: good_green width: 6;
						int edge_distance_in_cms <- round(edge_geom.points[0] distance_to edge_geom.points[1]);
						
						float offset_x <- abs(edge_geom.points[0].x-edge_geom.points[1].x);
						float offset_y <- abs(edge_geom.points[0].y-edge_geom.points[1].y)/10;
						
						float offset_x_aux <- offset_x * (offset_y/2);
						float offset_y_aux <- offset_y * (offset_x/2);
						
						point middle_of_the_line <- {((edge_geom.points[0].x+edge_geom.points[1].x)/2)+5,((edge_geom.points[0].y+edge_geom.points[1].y)/2)-offset_y};
						draw(string(edge_distance_in_cms)) color: good_green rotate:90 at: middle_of_the_line font:font("SansSerif", 25 , #plain);
					}
				}
			}
			
			graphics "connectivity_graph" {
				if(drawConnectivityGraph){
					loop eg over: connectivity_graph.edges {
						geometry edge_geom <- geometry(eg);

						if (drawConnectivityConnector = "curve")
						{
							draw curve(edge_geom.points[0],edge_geom.points[1], 0.5, 100, 0) color: good_blue width: 6 end_arrow: 6;
						}
						else
						{
							// blue arrow
							draw line(edge_geom.points) color: good_blue width: 8 end_arrow: 6;						
						}
						
					}
					// empty graph to draw only the last timestamp
					connectivity_graph <- graph([]);
				}
			}
			
			graphics "merkle_exchange_graph" {				
				if(drawMerkleExchangeGraph){
					loop eg over: merkle_exchange_graph.edges {
						geometry edge_geom <- geometry(eg);
						// red arrow
						draw line(edge_geom.points) color: good_red width: 6 end_arrow: 6;
					}
					// empty graph to draw only the last timestamp
					merkle_exchange_graph <- graph([]);
				}
				// remove the highlight property of the source robot
				highlight nil;
			}
			
			
			graphics "merkle_query_graph" {				
				if(drawMerkleQueryGraph){
					loop eg over: merkle_query_graph.edges {
						geometry edge_geom <- geometry(eg);
						draw line(edge_geom.points) color: good_green width: 6 end_arrow: 6;
					}
					// empty graph to draw only the last timestamp
					merkle_query_graph <- graph([]);
				}
			}
		}
	}
}

experiment TangibleSwarm_Inititalization_State type: gui {
	parameter "Display arena extended info:" var:DrawExtendedInfo <- false category: "Experiment Initialization";
	output {
		display objects_display_init type:opengl toolbar: false rotate: 90 background: #black fullscreen:1 draw_env: false keystone: arena_keystone
		{	
			species arena aspect: initialization_state position: {0,0,-0.001};	
		}
	}
}

experiment TangibleSwarm_Simulator parent: MainTangibleSwarmExperiment type: gui {
	output {
		display objects_display_simulator parent:objects_display background: #black fullscreen:0 draw_env: false autosave: recording_experiment
		{		
			species arena aspect: simulator position: {0,0,-0.001};
		}
	}
}

experiment TangibleSwarm_Projector parent: MainTangibleSwarmExperiment type: gui {
	output {
		display objects_display_projector parent:objects_display background: #black fullscreen:1 draw_env: false keystone: arena_keystone
		{	
			species arena aspect: projector position: {0,0,-0.001};	
		}
	}
}
