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

A road can be composed of several lanes and the vehicles will be able to change at any time its lane. What a lane represents will depend a lot on the context of application. Typically, if in developed countries, the lanes are most of times well defined, in many other countries this notion is much more abstract. For example in Vietnam where the main means of locomotion is the motorcycle, a lane can designate a "place" for a motorcycle and thus be much narrower than classical lanes. Another property of the road that will be taken into account is the maximal authorized speed on it. Note that even if the user of the plug-in has no information about these values for some of the roads (the OSM data are often incomplete), it is very easy using the GAML language to fill the missing value by a default value. It is also possible to change these values dynamically during the simulation (for example, to take into account that after an accident, a lane of a road is closed or that the speed of a road is decreased by the authorities).


![Roads representation in the driving skill.](/resources/images/recipes/roads.PNG) 

The **road skill** (`skill_road`) provides the road agents with several variables that will define the road properties:

* **`num_lanes`**: integer, number of lanes.
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

A vehicle is first characterized by its location, a 3D-point (coordinate) that represents the centroid of the vehicle. The actual geometry of the vehicle is not taken into account. However, the size of a vehicle is determined by two attributes: `vehicle_length` and `num_lanes_occupied`. Indeed, if we go back to our Vietnamese example where the lanes are defined according to the size of the motorcycles, we can consider that a motorcycle will occupy one lane, but that a car, which is much wider, will occupy two.

Each vehicle agent has also a planned trajectory that consists of a succession of edges. When the vehicle agent enters a new edge, it first chooses its lane according to the traffic density, with a bias for the rightmost lane. The movement on an edge is inspired by the Intelligent Driver Model. The drivers have the possibility to change their lane at any time (and not only when entering a new edge). The lane-changing model is inspired from the MOBIL model.

The **advanced driving skill** (`advanced_driving `) provides the driver agents with several variables that will define the car properties and the personality of the driver:

* **`final_target`**: point; final location that the agent wants to reach (its goal).
* **`vehicle_length`**: float; length of the vehicle.
* **`num_lanes_occupied`**: float; the number of lanes occupied by the vehicle.
* **`max_acceleration`**: float; maximal acceleration of the vehicle.
* **`max_speed`**: float; maximal speed of the vehicle.
* **`right_side_driving`**: boolean; do drivers drive on the right side of the road?
* **`speed_coeff`**: float; coefficient that defines if the driver will try to drive above or below the speed limits.
* **`safety_distance_coeff`**: float; coefficient for the security distance. The security distance will depend on the driver speed and on this coefficient.
* **`proba_lane_change_up`**: float; probability to change lane to an upper lane if necessary (and if possible).
* **`proba_lane_change_down`**: float; probability to change lane to a lower lane if necessary (and if possible).
* **`proba_use_linked_road`**: float; probability to take the reverse road if necessary (if there is a reverse road).
* **`proba_respect_priorities`**: float; probability to respect left/right (according to the driving side) priority at intersections.
* **`proba_respect_stops`**: list of float; probabilities to respect each type of stop signals (traffic light, stop sign...).
* **`proba_block_node`**: float; probability to accept to block the intersecting roads to enter a new road.
* **`lane_change_cooldown`**: float;  the duration that a vehicle must wait before changing lanes again
* **`max_safe_deceleration`**: float;  the maximum deceleration that the vehicle is willing to induce on its back vehicle when changing lanes. Known as the parameter 'b_save' in the MOBIL lane changing model
* **`min_safety_distance`**: float; the minimum distance of the vehicle's front bumper to the leading vehicle's rear bumper, known as the parameter 
s0 in the Intelligent Driver Model
* **`lane_change_limit`**: int; the maximum number of lanes that the vehicle can change during a simulation step
* **`acc_gain_threshold`**: float; the minimum acceleration gain for the vehicle to switch to another lane, introduced to prevent frantic lane changing. Known as the parameter 'a_th' in the MOBIL lane changing model
* **`linked_lane_limit`**: int; the maximum number of linked lanes that the vehicle can use; the default value is -1, i.e. the vehicle can use all available linked lanes
* **`ignore_oneway`**: bool; if set to `true`, the vehicle will be able to violate one-way traffic rule
* **`lowest_lane`**: int; the lane with the smallest index that the vehicle is in
* **`acc_bias`**: float; the bias term used for asymmetric lane changing, parameter 'a_bias' in MOBIL
* **`allowed_lanes`**: list of int; a list containing possible lane index values for the attribute lowest_lane
* **`time_headway`**: float; the time gap that to the leading vehicle that the driver must maintain. Known as the parameter 'T' in the Intelligent Driver Model
* **`delta_idm`**: float; the exponent used in the computation of free-road acceleration in the Intelligent Driver Model
* **`max_deceleration`**: float; the maximum deceleration of the vehicle. Known as the parameter 'b' in the Intelligent Driver Model
* **`politeness_factor`**: float; determines the politeness level of the vehicle when changing lanes. Known as the parameter 'p' in the MOBIL lane changing model


It provides as well the driver agents with several read-only variables:

* **`speed`**: float; speed expected according to the road **`max_value`**, the car properties, the personality of the driver and its **`real_speed`**.
* **`real_speed`**: float; real speed of the car (that takes into account the other drivers and the traffic signals).
* **`current_path`**: path (list of roads to follow); the path that the agent is currently following.
* **`current_road`**: agent; the road on which the agent is driving on.
* **`lowest_lane`**: agent; the index of the lowest lane occupied.
* **`current_target`**: point; the next target to reach (sub-goal). It corresponds to a node.
* **`targets`**: list of points; list of locations (sub-goals) to reach the final target.
* **`current_index`**: integer; the index of the current goal the agent has to reach.
* **`using_linked_road`**: boolean; is the agent on the linked road?

Of course, the values of these variables can be modified at any time during the simulation. For example, the probability to take a reverse road (**proba\_use\_linked\_road**) can be increased if the driver is stuck for several minutes behind a slow vehicle.

In addition, the advanced driving skill provides driver agents with several actions:

* **`compute_path`**: arguments: a graph and a target node. This action computes from a graph the shortest path to reach a given node.
* **`drive`**: no argument. This action moves the driver on its current path according to the traffic condition and the driver properties (vehicle properties and driver personality). The **`drive_random`** make the agent drives on a road and chooses randomly a new road at each intersection.


The `drive` action works as follow: while the agent has the time to move (`remaining_time > 0`), it first defines the speed expected. This speed is computed from the `max_speed` of the road, the current `real_speed`, the `max_speed`, the `max_acceleration` and the `speed_coef` of the driver.

Then, the agent moves toward the current target and compute the remaining time. During the movement, the agents can change lanes. If the agent reaches its final target, it stops; if it reaches its current target (that is not the final target), it tests if it can cross the intersection to reach the next road of the current path. If it is possible, it defines its new target (target node of the next road) and continues to move.

The function that defines if the agent crosses or not the intersection to continue to move works as follow: first, it tests if the road is blocked by a driver at the intersection (if the road is blocked, the agent does not cross the intersection). Then, if there is at least one stop signal at the intersection (traffic signal, stop sign...), for each of these signals, the agent tests its probability to respect or not the signal (note that the agent has a specific probability to respect each type of signals). If there is no stopping signal or if the agent does not respect it, the agent checks if there is at least one vehicle coming from a right (or left if the agent drives on the left side) road at a distance lower than its security distance. If there is one, it tests its probability to respect this priority. If there is no vehicle from the right roads or if it chooses to do not respect the right priority, it tests if it is possible to cross the intersection to its target road without blocking the intersection (i.e. if there is enough space in the target road). If it can cross the intersection, it crosses it; otherwise, it tests its probability to block the node: if the agent decides nevertheless to cross the intersection, then the perpendicular roads will be blocked at the intersection level (these roads will be unblocked when the agent is going to move).

Concerning the movement of the driver agents on the current road, the agent moves from a section of the road (i.e. segment composing the polyline) to another section according to the maximal distance that the agent can moves (that will depend on the remaining time). For each road section, the agent first computes the maximal distance it can travel according to the remaining time and its speed. Then, the agent computes its security distance according to its speed and its `safety_distance_coeff`. While its remaining distance is not null, the agent computes the maximal distance it can travel (and the corresponding lane), then it moves according to this distance (and update its current lane if necessary). If the agent is not blocked by another vehicle and can reach the end of the road section, it updates its current road section and continues to move.

The computation of the maximal distance an agent can move on a road section consists of computing for each possible lane the maximal distance the agent can move. First, if there is a lower lane, the agent tests the probability to change its lane to a lower one. If it decides to test the lower lane, the agent computes the distance to the next vehicle on this lane and memorizes it. If this distance corresponds to the maximal distance it can travel, it chooses this lane; otherwise, it computes the distance to the next vehicle on its current lane and memorizes it if it is higher than the current memorized maximal distance. Then if the memorized distance is lower than the maximal distance the agent can travel and if there is an upper lane, the agents test the probability to change its lane to an upper one. If it decides to test the upper lane, the agent computes the distance to the next vehicle on this lane and memorizes it if it is higher than the current memorized maximal distance. At last, if the memorized distance is still lower than the maximal distance it can travel if the agent is on the highest lane and if there is a reverse road, the agent tests the probability to use the reverse road (linked road). If it decides to use the reverse road, the agent computes the distance to the next vehicle on the lane 0 of this road and memorizes the distance if it is higher than the current memorized maximal distance.

More details about the driving skill can be found [here](http://agents.fel.cvut.cz/att2014/att2014_paper_3.pdf)
