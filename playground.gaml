/**
* Name: playground
* Author: nati
* Description: to play around with new ideas
* Tags: Tag1, Tag2, TagN
*/

model playground

global{
	
	int nb_tasks <-1;
	int nb_rovers <- 5;
	float dist_to_goal;
	float battery_life max:100.0 min:0.0;
	file shape_file_in <- file('../includes/road.shp') ;
	geometry shape <- envelope(shape_file_in);
	graph the_graph; 
	init{
		create roads from:shape_file_in;
		the_graph <-as_edge_graph(roads);
		
		create tasks number: nb_tasks {
			location <- any_location_in (one_of(roads));
			
		}
		create rovers number: nb_rovers {
			target <- one_of(tasks);
			location <- any_location_in (one_of(roads));
		}
		
	} 
		
}

species roads{
	aspect default{
		draw shape color: #black;
	}
}

species tasks{
	
	aspect default{
		draw circle(10) color: #blue;
	}
}
species rovers skills: [moving]{
	
	point target;
	float short_dist_count;
	float dist_to_target;
	float battery_life <- 100.0;
	
	reflex move when: location distance_to target <= short_dist_count  {
		
		if battery_life <= 100 and battery_life >=0 and location distance_to target >= 0.5{
			do  goto on:the_graph target:target speed:0.5;
				battery_life <- battery_life - 0.5;
		}
		else if battery_life <= 0{
			do die;
		}
		
	
		
		//write self.battery_life;
	}
	
	
	
	reflex check_dist{
		
		ask tasks{
			agent closest_rov <- rovers closest_to(self);
			write closest_rov.name;
			myself.short_dist_count <- closest_rov distance_to self;
			write myself.short_dist_count;
			myself.dist_to_target <- myself distance_to self;
			
			if(myself.short_dist_count = 0){
				write 'Task Completed';
			}
			
			
			//try this
			/*if(myself is farthest_to self ){
				do die;
			}*/
			}
			
	}
	aspect base {
		draw circle(5) color: #red;
		
	}
}
experiment my_exp type:gui{
	output {
		display my_disp{
			species roads aspect:default;
			species rovers aspect:base;
			species tasks aspect:default;	
		}
	inspect "All Rovers" type:table value:rovers attributes: ["name","location"];
	inspect "All Tasks" type:table value:tasks attributes:["name", "location"];
	}
}

