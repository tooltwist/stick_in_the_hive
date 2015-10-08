# stick_in_the_hive
***The fastest way to create a swarm!***


This project provides scripts to:
* Swarms: quickly create and administer
* Applications: build and publish Docker images
* Deploy: run applications on swarms


#### Team Based Control of Swarms
These scripts are normally run within a Docker container, co-located with your swarms.

Docker-machine provides a simple way for a user to start and control multiple remote Docker machines,
but it does not make it easy for multiple users to share the definitions of those machines.

These scripts provide menus that simplify running docker-machine in a central location,
where it's functionality can be shared by an entire team.

Rather than having multiple users uploading and downloading Docker images, and fragmenting
devops across multiple user's machines, these operations can occur on a single remote server,
which may have faster access to Docker Hub and other resources used while building applications and running Dockerfiles.


#### Roles
Several roles are facilitated by these scripts:

- Developer
  Creates an application, deploys it as a docker image.  
  Provides Compose definition for development and testing.  
  Can start and stop applications on non-staging and non-production swarms.

- Operations
  Providing and maintaining swarms used for:  
    a) development, testing and Continuous Integration  
    b) staging and production  
  Provide Compose definitions and configurations for staging and production.  
  Can start and stop applications on all swarms.

While it may be possible for a malicious user to bypass the role-based intent of these scripts, it is not usually possible to do by accident.



