
# Abstract

Tangible Swarm is a tool that displays relevant information about a robotics system (e.g., multi-robot, swarm, etc.) in real time while the system is physically conducting its mission. Information such as robots' IDs, sensor inputs, robot trajectories, distance between robots, battery status, communication patterns, etc. can be easily displayed and customized for different missions and scenarios. Tangible Swarm is developped using the [Gama Platform](https://gama-platform.github.io/).

A demo video here:

[![Tangible Swarm Demo](https://img.youtube.com/vi/ksInHOlYSV4/maxresdefault.jpg)](https://youtu.be/ksInHOlYSV4)

# Installation
  - Clone this repository
  - Download GAMA (compatible with GAMA 1.8.1) [here](https://gama-platform.github.io/download)
  - Run GAMA, 
  - Choose a new Workspace (this is a temporay folder used for computation)
  - right click on User Models->Import->GAMA Project..
  - Select TangibleUrbanSwarm in the folder that you have cloned

# Models

This repository has two working models represented as repo branches:

  - *Maze-formation*: this models displays a rectangular area of 2.5 x 2.5 m2 where robots need to discover and occupy cells in a grid in order to form a custom maze. This GAMA model receives information from the robots and displays their position, internal variable status (e.g., number of completed merkle tree leaves), and communication patterns. A demo can be seen here: https://youtu.be/6-1mGT9JmNA

  - *Foraging*: this model displays a rectangular area of 2.5 x 2.5 m2 within which robots, objects to be retrieved (represented as colored cells), and a target area (0.5 x 0.5 m2) located at the center are placed. This model receives information from the robots and displays their position, internal variable status (e.g., number of completed merkle tree leaves), and communication patterns. In addition, it displays the position of the objects to be retrieved (i.e., colored cells) and the status of the sequence to complete (i.e., color sequence in the central grid). A demo can be seen here: https://youtu.be/OprpktwwbRE


# Additional information:

Tangible Swarm is a tool developed to complement the [Blockchain: a new framework for swarm robotic systems](https://www.media.mit.edu/projects/blockchain-a-new-framework-for-swarm-robotic-systems/overview/) research project. Detailed information about the system setup as well as configuration parameters can be found in the supplementary material of the paper titled ["Secure and secret cooperation in robot swarms"](https://robotics.sciencemag.org/content/6/56/abf1538).
