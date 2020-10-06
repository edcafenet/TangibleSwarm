model TangibleUrbanSwarm

global {

	// Global variables
	int i <- 0;
	string url;
	int port;
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
	bool DrawExtendedInfo;
	
	// Projector colors
	rgb good_blue <- rgb(50, 150, 255, 225);
	rgb area_blue <- rgb(25, 90, 255, 255);
	rgb good_red <- rgb(255,100,50,255);
	rgb good_green <- rgb(0,255,0,255);
	

	init {
		create epuck number:number_of_epucks {
		   do connect to: url protocol: "udp_server" port: port+i;
		   i<-i+1;
		}
	}

	reflex updateProximityGraph when:(drawProximityGraph) {
		proximity_graph <- graph<epuck, epuck>(epuck as_distance_graph(proximity_graph_distance));
	}
}

grid arena cell_width:50 cell_height:50 {
	// Display the arena with the cell border lines
	aspect simulator{
		draw shape color:#black border:#black width:5;	
	}
	
	// Display the arena without the cell border lines to not interfere with the tracking system
	aspect projector{
		draw shape color: #black border:#black width:5;
		
		if (DrawExtendedInfo)
		{	
			if (time > 300)
			{
				draw("ENTRANCE") color:#white at: {25, 154, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw arena[0,3] color:area_blue border:#black width:5;
				draw arena[4,1] color:#forestgreen border:#black width:5;
				draw("EXIT") color:#white at: {225, 65, 0.5} font:font("Helvetica", 30 , #plain) bitmap:false rotate: 90;	
			} 
			
			if (time > 500)
			{
				// path between entrance and exit
				path success_path <- path([{50,175}, {175,175}, {175,75}, {200,75}]);
				
				loop segment over: success_path.edges 
				{
			  		draw segment color: good_red width: 8;
			 	}
		 	}
		 	
		 	if (time > 1000)
			{
			 	// draw the actual maze
			 	rgb color_maze <- #grey;
			 	draw arena[0,0] color:color_maze border:#black width:5;
			 	draw arena[1,0] color:color_maze border:#black width:5;
			 	draw arena[2,0] color:color_maze border:#black width:5;
			 	draw arena[3,0] color:color_maze border:#black width:5;
			 	draw arena[4,0] color:color_maze border:#black width:5;
			 	
			 	draw arena[4,2] color:color_maze border:#black width:5;
			 	draw arena[4,3] color:color_maze border:#black width:5;
			 	draw arena[4,4] color:color_maze border:#black width:5;
			 	
			 	draw arena[3,4] color:color_maze border:#black width:5;
			 	draw arena[2,4] color:color_maze border:#black width:5;
			 	draw arena[1,4] color:color_maze border:#black width:5;
			 	draw arena[0,4] color:color_maze border:#black width:5;
			 	
			 	draw arena[0,2] color:color_maze border:#black width:5;
			 	draw arena[0,1] color:color_maze border:#black width:5;
			 	draw arena[2,1] color:color_maze border:#black width:5;
			 	draw arena[2,2] color:color_maze border:#black width:5;			 	
			}
			
			if (time > 1250)
			{
				draw("TASK 1") color:#black at: {25, 10, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 2") color:#black at: {75, 10, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 3") color:#black at: {125, 10, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 4") color:#black at: {175, 10, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 5") color:#black at: {225, 10, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 6") color:#black at: {225, 110, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 7") color:#black at: {225, 160, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 8") color:#black at: {225, 210, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 9") color:#black at: {175, 210, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 10") color:#black at: {125, 210, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 11") color:#black at: {75, 210, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 12") color:#black at: {25, 210, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 13") color:#black at: {25, 110, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 14") color:#black at: {25, 60, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 15") color:#black at: {125, 60, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;
				draw("TASK 16") color:#black at: {125, 110, 0.5} font:font("Helvetica", 32 , #plain) bitmap:false rotate: 90;	
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
	bool first_time_to_display_leaf <- true;
	date time_to_display_leaf;
			
	// Neighbor-related variables
	list<int> neighbors_ids;
	list<float> neighbors_ranges;

	reflex fetch when:has_more_message() {
		loop while:has_more_message()
		{
			message s <- fetch_message();
			//write string(s.contents);

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
				{	loop x from: 0 to: number_of_neighbors - 1
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
								merkle_query_graph <- merkle_query_graph add_edge(myself.location :: self.location );	
						}
					}
				}		
	}

	reflex when: (draw_trajectory = true) {
    	loop while:(length(current_trajectory) > trajectory_length){
	    		current_trajectory >> first(current_trajectory);
       		}
        	current_trajectory << location;
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
			int distance_in_cms <- -36;
			string epuck_id <- 'R' + string(int(copy_between(epuck_name, 7, 9)) - first_robot_id + 1);
			draw (epuck_id) color:#white border:#white at:{(location.x-10) + gravity_vector.x * distance_in_cms, (location.y+5) + gravity_vector.y * distance_in_cms} font:font("SansSerif", 30 , #italic);
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
		
		// Draw completed merkle tree leafs
		if(draw_completed_merkle_leafs){
			list<int> completed_leafs_list <- columns_list(completed_merkle_matrix)[0];
			int number_of_completed_leafs <- completed_leafs_list count (each = 1);
			
			point vector <- {arena_center.x - location.x, arena_center.y - location.y};
			float length <- distance_to(arena_center, location);
			point gravity_vector <- {vector.x / length, vector.y / length}; 
			int distance_in_cms <- 12;
			
			draw string(number_of_completed_leafs) color:#white at:{location.x + gravity_vector.x * distance_in_cms, location.y + gravity_vector.y * distance_in_cms} rotate:90 font:font("SansSerif", 25 , #plain);
			
		}

		// Robot Tracjectory
		if(draw_trajectory){
			loop j from: 0 to: length(current_trajectory) {
				rgb color_trajectory <- blend(good_blue, good_green, j/length(current_trajectory));
			 	draw circle(robot_size) at_location current_trajectory[j] empty:true color: rgb(color_trajectory,trajectory_alpha);
		    }
		}
	}
}

experiment MainTangibleSwarmExperiment type: gui virtual: true {
	
	// Minimum cycle duration
	float minimum_cycle_duration<-0.04;
	
	// GENERAL PARAMETERS
	parameter "Number of epucks:" var: number_of_epucks <- 28 category: "General parameters" min: 0 max:100;
	
	// NETWORK PARAMETERS
	parameter "UDP port of first agent:" var: port <- 9820 category:"Network connectivity";
	parameter "UDP address:" var: url <- "localhost" category: "Network connectivity";

	// EXPERIMENT PARAMETERS
	parameter "Capture:" var: recording_experiment <- false category: "Experiment Initialization";
	parameter "Display arena extended info:" var:DrawExtendedInfo <- false category: "Experiment Initialization";

	// VIZ PARAMETERS
    parameter "Show robot:" var: show_robot <- true  enables:[robot_size, draw_robot_name, draw_IR, drawProximityGraph, drawConnectivityGraph, draw_trajectory] category: "Viz Interaction";
    parameter "Robot size:" var: robot_size <- 5 min:1.0 max:10.0 category: "Viz Interaction";
    parameter "Draw robot name:" var: draw_robot_name <-false category: "Viz Interaction";
    parameter "Draw proximity sensors:" var: draw_IR <-false category: "Viz Interaction";
    parameter "Draw battery level:" var: draw_battery_level <-false category: "Viz Interaction";
	parameter "Draw proximity graph:" var:drawProximityGraph <- true enables:[proximity_graph_distance] category: "Connectivity Interaction";
	parameter "Proximity graph distance" var: proximity_graph_distance <- 50 category: "Connectivity Interaction" min: 1 max:150;
	parameter "Draw connectivity graph:" var:drawConnectivityGraph <- true enables:[drawConnectivityConnector] category: "Connectivity Interaction";
	parameter "Shape of connector:" var: drawConnectivityConnector <- "line" among: ["line", "curve"] category: "Connectivity Interaction";
	parameter "Draw merkle information:" var:draw_completed_merkle_leafs <- true enables:[drawMerkleExchangeGraph, drawMerkleQueryGraph] category: "Connectivity Interaction";
	parameter "Draw merkle exchage graph:" var:drawMerkleExchangeGraph <- true category: "Connectivity Interaction";
	parameter "Draw merkle query graph:" var:drawMerkleQueryGraph <- true category: "Connectivity Interaction";
	parameter "Trajectory:" category: "Viz Interaction" var:draw_trajectory <- true enables:[trajectory_length, trajectory_alpha];
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
						
						point middle_of_the_line <- {((edge_geom.points[0].x+edge_geom.points[1].x)/2),((edge_geom.points[0].y+edge_geom.points[1].y)/2)+5};
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
		display objects_display_simulator parent:objects_display fullscreen:0 autosave: recording_experiment
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



