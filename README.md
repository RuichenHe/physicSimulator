# Physically-Based Animation
# [About](https://ruichenhe.github.io/physicSimulator/)
A project for *CSCI 5611: Animation and Planning in Games*. **physicSimulator** is a combination of several physically-based simulation of 3D cloth, and 1D water written in Processing.Inside the project, the cloth3D is a 3D cloth simulation with texuture rendered for a Halloween theme. The shallowWater1D is a 1D simulation of Shallow Water.
## Author: *Ruichen He*

# cloth3D
cloth3D is a 3D cloth simulation. In the scene, a squere cloth (1.5m by 1.5m) is simulated and rendered. 6x6 mesh is used to discritize the cloth plane. Hozizontal and vertical edges for each mesh block is set to be a link, which has a pre-defined length constraint. Next to the cloth, there is a ball rendered as well, which will be served as a collision object later in the simulation. Initially, the cloth is hanging horizontally without any motion.Two corner (along same edge) is set to be Base type,i.e. no movement. All the other nodes of the mesh is set to be moveable during the simulation. 
## Demo1
![](https://github.com/RuichenHe/physicSimulator/blob/main/doc/cloth3D_demo1.gif)

<img src="{{ "doc/cloth3D_demo1.gif" | prepend: site.baseurl | prepend: site.url}}" alt="cloth3D_demo1" />

In the first demo gif, the following features have been presented (80):
+ **Multiple Ropes** (45)
+ **Cloth Simulation**(20)
+ **3D Simulation**(10)
+ **High-quality Rendering**(5)
## Demo2
![](https://github.com/RuichenHe/physicSimulator/blob/main/doc/cloth3D_demo2.gif)

<img src="{{ "doc/cloth3D_demo2.gif" | prepend: site.baseurl | prepend: site.url}}" alt="cloth3D_demo2" />

In the second demo gif, I compare the simulation with a real world squere cloth movement to demonstrate the realistice speed of the simulation (5):
+ **Realistic Speed**(5)
## Demo3
![](https://github.com/RuichenHe/physicSimulator/blob/main/doc/cloth3D_demo3.gif)

<img src="{{ "doc/cloth3D_demo3.gif" | prepend: site.baseurl | prepend: site.url}}" alt="cloth3D_demo3" />
In the third demo gif, I enable the air drag force. By comparing with Demo1, it is clear to see the impact of the air drag force, reducing the speed of the falling cloth (10):
+ **Air Drag for Cloth**(10)
## Demo4
In the 4th demo, I show the interaction in the simulation. There are two ways of interaction. User can click the nodes to change the moveable nodes into Base type temporaryly (during the clicking of the mouse). User can also click the Base nodes (indicated by white visual balls), and drag it to a certain degree, then the Base node will be destryed, and transfer to a movable Node type. This demo demonstrate the following features (5):
+ **User Interaction**(5)

# shallowWater1d
shallowWater 1d is a simulation of 1D shallow water. In the scene, a 1D water with intial surface height differences representing a dam break scene has been simulated with midpoint integration method. To make the scene realistic, a 2D pixel island sea art scene has been created using ChatGPT4 + DALL.E3. In addition, each 1d block of the water is rendered based on its height. The left and right boundary are set as 
reflective. To start the simulation, press `Space`. To restart the simulation, press `r`. 
## Demo1 **(Art Contest)**
![](https://github.com/RuichenHe/physicSimulator/blob/main/doc/shallowWater1D.gif)

<img src="{{ "doc/shallowWater1D.gif" | prepend: site.baseurl | prepend: site.url}}" alt="shallowWater1D" />

In this demo, I present the 1D shallow water simulation with a dam breaking initial setup, the following features have been presented (30):
+ **Flow smoothly**
+ **Execute in real-time**
+ **Rendered to look like actual fluid**
+ **Placed in a beach scene**
Youtube video version of this demo also has a music played during the simulation. 
