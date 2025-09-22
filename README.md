# tech_eazy_devops_Chamundeshwari-D

## Assignment: Lift & Shift

This repository contains the automation scripts for the TechEazy DevOps internship assignment.

### What I Did
* Used a cloud-init script (`user-data.sh`) to automatically bootstrap a fresh Ubuntu 22.04 EC2 instance.
* The script installs OpenJDK 21, Maven, and Git.
* It then clones the assignment repository, builds the application, and starts it as a background service using `systemd`.
* The application is accessible on port 80.

### Validation
* **Public IP Address:** `http://13.60.23.140/hello` 
