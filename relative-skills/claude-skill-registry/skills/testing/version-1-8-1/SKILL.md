---
title:  Advanced Driving Skill
---

[//]: # (keyword|concept_transport)
[//]: # (keyword|concept_skill)
[//]: # (keyword|skill_driving)


This page aims at presenting how to use the advanced driving skill in models.

The use of the advanced driving skill requires to use 3 skills:

* **Advanced driving skill**: dedicated to the definition of the driver species. It provides the driver agents with variables and actions allowing to move an agent on a graph network and to tune its behavior.
* **Road skill**: dedicated to the definition of roads. It provides the road agents with variables and actions allowing to registers agents on the road.
* **Road node skill**: dedicated to the definition of nodes. It provides the node agents with variables allowing to take into account the intersection of roads and the traffic signals.

## Table of contents 

* [Advanced Driving Skill](#advanced-driving-skill)
  * [Structure of the network: road and road node skills](#structure-of-the-network-road-and-road-node-skills)
  * [Advanced driving skill](#advanced-driving-skill)
  * [Application example](#application-example)


## Structure of the network: road and road_node skills

The advanced driving skill is versatile enough to be usable with most of classic road GIS data, in particular, OSM data. We use a classic format for the roads and nodes. Each road is a polyline composed of road sections (segments). Each road has a target node and a source node. Each node knows all its input and output roads. A road is considered as directed. For bidirectional roads, 2 roads have to be defined corresponding to both directions. Each road will be the **`linked_road`** of the other. Note that for some GIS data, only one road is defined for bidirectional roads, and the nodes are not explicitly defined. In this case, it is very easy, using the GAML language, to create the reverse roads and the corresponding nodes (it only requires a few lines of GAML).


![Road structure in the Driving Skill](/resources/images/recipes/roads_structure.PNG) 

A lane can be composed of several lanes and the vehicles will be able to change at any time its lane. Another property of the road that will be taken into account is the maximal authorized speed on it. Note that even if the user of the plug-in has no information about these values for some of the roads (the OSM data are often incomplete), it is very easy using the GAML language to fill the missing value by a default value. It is also possible to change these values dynamically during the simulation (for example, to take into account that after an accident, a lane of a road is closed or that the speed of a road is decreased by the authorities).


![Roads representation in the driving skill.](/resources/images/recipes/roads.PNG) 

The **road skill** (`skill_road`) provides the road agents with several variables that will define the road properties:

* **`lanes`**: integer, number of lanes.
* **`maxspeed`**: float; maximal authorized speed on the road.
* **`linked_road`**: road agent; reverse road (if there is one).
* **`source_node`**: node agent; source node of the road.
* **`target_node`**: node agent; target node of the road.


It provides as well the road agents with read-only variables:

* **`agents_on`**: list of list (of driver agents); for each lane, the list of driver agents on the road.
* **`all_agents`**: list (of driver agents): the list of agents on the road.



The **road node skill** (`skill_road_node`) provides the road node agents with several variables that will define the road node properties:

* **`roads_in`**: list of road agents; the list of road agents that have this node for target node.
* **`roads_out`**: list of road agents; the list of road agents that have this node for source node.
* **`stop`**: list of list of road agents; list of stop signals, and for each stop signal, the list of concerned roads.
* **`priority_roads`**: list of road agents: the list of priority roads.


It provides as well the road agents with one read-only variable:

* **`block`**: map: key: driver agent, value: list of road agents; the list of driver agents blocking the node, and for each agent, the list of concerned roads.


## Advanced driving skill
Each driver agent has a planned trajectory that consists of a succession of edges. When the driver agent enters a new edge, it first chooses its lane according to the traffic density, with a bias for the rightmost lane. The movement on an edge is inspired by the Intelligent Driver Model. The drivers have the possibility to change their lane at any time (and not only when entering a new edge).

The **advanced driving skill** (`advanced_driving `) provides the driver agents with several variables that will define the car properties and the personality of the driver:

* **`final_target`**: point; final location that the agent wants to reach (its goal).
* **`vehicle_length`**: float; length of the vehicle.
* **`max_acceleration`**: float; maximal acceleration of the vehicle.
* **`max_speed`**: float; maximal speed of the vehicle.
* **`right_side_driving`**: boolean; do drivers drive on the right side of the road?
* **`speed_coef`**: float; coefficient that defines if the driver will try to drive above or below the speed limits.
* **`security_distance_coeff`**: float; coefficient for the security distance. The security distance will depend on the driver speed and on this coefficient.
* **`proba_lane_change_up`**: float; probability to change lane to an upper lane if necessary (and if possible).
* **`proba_lane_change_down`**: float; probability to change lane to a lower lane if necessary (and if possible).
* **`proba_use_linked_road`**: float; probability to take the reverse road if necessary (if there is a reverse road).
* **`proba_respect_priorities`**: float; probability to respect left/right (according to the driving side) priority at intersections.
* **`proba_respect_stops`**: list of float; probabilities to respect each type of stop signals (traffic light, stop sign...).
* **`proba_block_node`**: float; probability to accept to block the intersecting roads to enter a new road.


It provides as well the driver agents with several read-only variables:

* **`speed`**: float; speed expected according to the road **`max_value`**, the car properties, the personality of the driver and its **`real_speed`**.
* **`real_speed`**: float; real speed of the car (that takes into account the other drivers and the traffic signals).
* **`current_path`**: path (list of roads to follow); the path that the agent is currently following.
* **`current_target`**: point; the next target to reach (sub-goal). It corresponds to a node.
* **`targets`**: list of points; list of locations (sub-goals) to reach the final target.
* **`current_index`**: integer; the index of the current goal the agent has to reach.
* **`on_linked_road`**: boolean; is the agent on the linked road?


Of course, the values of these variables can be modified at any time during the simulation. For example, the probability to take a reverse road (**proba\_use\_linked\_road**) can be increased if the driver is stuck for several minutes behind a slow vehicle.

In addition, the advanced driving skill provides driver agents with several actions:

* **`compute_path`**: arguments: a graph and a target node. This action computes from a graph the shortest path to reach a given node.
* **`drive`**: no argument. This action moves the driver on its current path according to the traffic condition and the driver properties (vehicle properties and driver personality).


The `drive` action works as follow: while the agent has the time to move (`remaining_time > 0`), it first defines the speed expected. This speed is computed from the `max_speed` of the road, the current `real_speed`, the `max_speed`, the `max_acceleration` and the `speed_coef` of the driver (see equation below).
```
speed_driver = Min(max_speed_driver, Min(real_speed_driver + max_acceleration_driver,max_speed_road * speed_coef_driver))
```

Then, the agent moves toward the current target and compute the remaining time. During the movement, the agents can change lanes (see below). If the agent reaches its final target, it stops; if it reaches its current target (that is not the final target), it tests if it can cross the intersection to reach the next road of the current path. If it is possible, it defines its new target (target node of the next road) and continues to move.


![Activity diagram describing the driver behavior.](/resources/images/recipes/drive_action.png) 

The function that defines if the agent crosses or not the intersection to continue to move works as follow: first, it tests if the road is blocked by a driver at the intersection (if the road is blocked, the agent does not cross the intersection). Then, if there is at least one stop signal at the intersection (traffic signal, stop sign...), for each of these signals, the agent tests its probability to respect or not the signal (note that the agent has a specific probability to respect each type of signals). If there is no stopping signal or if the agent does not respect it, the agent checks if there is at least one vehicle coming from a right (or left if the agent drives on the left side) road at a distance lower than its security distance. If there is one, it tests its probability to respect this priority. If there is no vehicle from the right roads or if it chooses to do not respect the right priority, it tests if it is possible to cross the intersection to its target road without blocking the intersection (i.e. if there is enough space in the target road). If it can cross the intersection, it crosses it; otherwise, it tests its probability to block the node: if the agent decides nevertheless to cross the intersection, then the perpendicular roads will be blocked at the intersection level (these roads will be unblocked when the agent is going to move).



![Activity diagram of driver behavior when stopped at an intersection.](/resources/images/recipes/stop_at_intersection.png) 


Concerning the movement of the driver agents on the current road, the agent moves from a section of the road (i.e. segment composing the polyline) to another section according to the maximal distance that the agent can moves (that will depend on the remaining time). For each road section, the agent first computes the maximal distance it can travel according to the remaining time and its speed. Then, the agent computes its security distance according to its speed and its `security_distance_coeff`. While its remaining distance is not null, the agent computes the maximal distance it can travel (and the corresponding lane), then it moves according to this distance (and update its current lane if necessary). If the agent is not blocked by another vehicle and can reach the end of the road section, it updates its current road section and continues to move.


![Activity diagram of the following action of the advanced driving skill.](/resources/images/recipes/follow_driving.png) 

The computation of the maximal distance an agent can move on a road section consists of computing for each possible lane the maximal distance the agent can move. First, if there is a lower lane, the agent tests the probability to change its lane to a lower one. If it decides to test the lower lane, the agent computes the distance to the next vehicle on this lane and memorizes it. If this distance corresponds to the maximal distance it can travel, it chooses this lane; otherwise, it computes the distance to the next vehicle on its current lane and memorizes it if it is higher than the current memorized maximal distance. Then if the memorized distance is lower than the maximal distance the agent can travel and if there is an upper lane, the agents test the probability to change its lane to an upper one. If it decides to test the upper lane, the agent computes the distance to the next vehicle on this lane and memorizes it if it is higher than the current memorized maximal distance. At last, if the memorized distance is still lower than the maximal distance it can travel if the agent is on the highest lane and if there is a reverse road, the agent tests the probability to use the reverse road (linked road). If it decides to use the reverse road, the agent computes the distance to the next vehicle on the lane 0 of this road and memorizes the distance if it is higher than the current memorized maximal distance.


![Activity diagram of the driver behavior to define its maximum distance to others.](/resources/images/recipes/define_max_dist.png) 

## Application example


We propose a simple model to illustrate the driving skill. We define a driver species. When a driver agent reaches its destination, it just chooses a new random final target. In the same way, we did not define any specific behavior to avoid traffic jam for the driver agents: once they compute their path (all the driver agents use for that the same road graph with the same weights), they never re-compute it even if they are stucked in a traffic jam. Concerning the traffic signals, we just consider the traffic lights (without any pre-processing: we consider the raw OSM data). One step of the simulation represents 1 second. At last, in order to clarify the explanation of the model, we chose to do not present the parts of the GAML code that concern the simulation visualization.



![Simple example of the driving skill.](/resources/images/recipes/sim_snapshot.png) 

The following code shows the definition of species to represent the road infrastructure:
```
species road skills: [skill_road] { 
    string oneway;
}

species road_node skills: [skill_road_node] {
    bool is_traffic_signal;
    int time_to_change <- 100;
    int counter <- rnd (time_to_change) ;
	
    reflex dynamic when: is_traffic_signal {
        counter <- counter + 1;
        if (counter >= time_to_change) { 
            counter <- 0;
            stop[0] <- empty(stop[0])? roads_in : [];
        } 
    }
}
```

In order to use our driving skill, we just have to add the `skill_road_node` to the `road_node` species and the `skill_road` to the `road` species. In addition, we added to the road species a variable called `oneway` that will be initialized from the OSM data and that represents the traffic direction (see the OSM map features for more details). Concerning the node, we defined 3 new attributes:

* **`is_traffic_signal`**: boolean; is the node a traffic light?
* **`time_to_change`**: integer; represents for the traffic lights the time to pass from the red light to the green light (and vice versa).
* **`counter`**: integer; number of simulation steps since the last change of light color (used by the traffic light nodes).

In addition, we defined for the `road_node` species a reflex (behavior) called **`dynamic`** that will be activated only for traffic light nodes and that will increment the `counter` value. If this counter is higher than `time_to_change`, this variable is set to 0, and the node change the value of the `stop` variable: if the traffic light was green (i.e. there are no road concerns by this stop sign), the list of block roads is set by all the roads that enter the node; if the traffic light was red (i.e. there is at least one road concerned by this stop sign), the list of block roads is set to an empty list.

The following code shows the definition of driver species:

```
species driver skills: [advanced_driving] { 
    reflex time_to_go when: final_target = nil {
        current_path <- compute_path(graph: road_network, target: one_of(road_node));
    }
    reflex move when: final_target != nil {
        do drive;
    }
} 
```

In order to use our driving plug-in, we just have to add the `advanced_driving` skill to the `driver` species. For this species, we defined two reflexes:

* **`time_to_go`**: activated when the agent has no final target. In this reflex, the agent will randomly choose one of the nodes as its final target, and computed the path to reach this target using the **`road_network`** graph. Note that it will have been possible to take into account the knowledge that each agent has concerning the road network by defining a new variable of type map (dictionary) containing for each road a given weight that will reflect the driver knowledge concerning the network (for example, the known traffic jams, its favorite roads....) and to use this map for the path computation.
* **`move`**: activated when the agent has a final target. In this reflex, the agent will drive in direction of its final target.

We describe in the following code how we initialize the simulation:
```
init {  
    create node from: file("nodes.shp") with:[
        is_traffic_signal::read("type")="traffic_signals"];
    
    create road from: file("roads.shp") 
        with:[lanes::int(read("lanes")), 
            maxspeed::float(read("maxspeed")), 
            oneway::string(read("oneway"))] 
    {
        switch oneway {
            match "no" {
                create road {
                    lanes <- myself.lanes;
                    shape <- polyline(reverse(myself.shape.points));
                    maxspeed <- myself.maxspeed;
                    linked_road <- myself;
                    myself.linked_road <- self;
                }
            }
            match "-1" {
                shape <- polyline(reverse(shape.points));
            }
        }
    }	
   
    map general_speed_map <-  road as_map(each::(each.shape.perimeter / (each.maxspeed)));
      
    road_network <-  (as_driving_graph(road, road_node)) with_weights general_speed_map;
   
    create driver number: 10000 { 
        location <- one_of(node).location;
        vehicle_length <- 3.0;
        max_acceleration <- 0.5 + rnd(500) / 1000;
        speed_coeff <- 1.2 - (rnd(400) / 1000);
        right_side_driving <- true;
        proba_lane_change_up <- rnd(500) / 500;
        proba_lane_change_down <- 0.5+ (rnd(250) / 500);
        security_distance_coeff <- 3 - rnd(2000) / 1000);  
        proba_respect_priorities <- 1.0 - rnd(200/1000);
        proba_respect_stops <- [1.0 - rnd(2) / 1000];
        proba_block_node <- rnd(3) / 1000;
        proba_use_linked_road <- rnd(10) / 1000;
    }	
}	
```

In this code, we create the node agents from the node shapefile (while reading the attributes contained in the shapefile), then we create in the same way the road agents. However, for the road agents, we use the `oneway` variable to define if we should or not reverse their geometry (`oneway` = "-1") or create a reverse road (`oneway` = "no"). Then, from the road and node agents, we create a graph (while taking into account the `maxspeed` of the road for the weights of the edges). This graph is the one that will be used by all agents to compute their path to their final target. Finally, we create 1000 driver agents. At initialization:

* they are randomly placed on the nodes; 
* their vehicle has a length of 3m; 
* the maximal acceleration of their vehicle is randomly drawn between 0.5 and 1; 
* the speed coefficient of the driver is randomly drawn between 0.8 and 1.2; 
* they are driving on the right side of the road; 
* their probability of changing lane for an upper lane is randomly drawn between 0 and 1.0; 
* their probability of changing lane for a lower lane is randomly drawn between 0.5 and 1.0; 
* the security distance coefficient is randomly drawn between 1 and 3; 
* their probability to respect priorities is randomly drawn between 0.8 and 1; 
* their probability to respect light signal is randomly drawn between 0.998 and 1;
* their probability to block a node is randomly drawn between 0 and 0.003;  

[The complete code of the model with the data can be found here](/resources/images/recipes/Rouentrafffic.zip).
