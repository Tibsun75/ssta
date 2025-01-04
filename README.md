# SSTA - Simple Traffic Analyzer

SSTA is a simple tool that helps you monitor your computer's current network connections. \
It shows all active connections along with their associated process IDs. \
Optionally, you can log the connections for 10 minutes into a log file.\
Features: \

* Displays active network connections and their process IDs
* Option to log connections for 10 minutes

# Permissions

To run the program correctly, the following Snap permissions must be granted:

network-observe\
process-control\
system-observe\
system-trace\
netlink-connector

# Execute the following commands to get permissions:
sudo snap connect ssta:network-observe\
sudo snap connect ssta:process-control\
sudo snap connect ssta:system-observe\
sudo snap connect ssta:system-trace\
sudo snap connect ssta:netlink-connector

# Usage
Simply run SSTA via the terminal:

ssta
