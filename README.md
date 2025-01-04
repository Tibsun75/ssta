# SSTA - Simple Traffic Analyzer

SSTA is a simple tool that helps you monitor your computer's current network connections. \
It shows all active connections along with their associated process IDs. \
Optionally, you can log the connections for 10 minutes into a log file.\

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

or open from gnome, kde etc.:
![grafik](https://github.com/user-attachments/assets/9abbd45f-fd62-42e5-b738-945b37bb67fe)


# Screenshots

Languages:
![grafik](https://github.com/user-attachments/assets/7b106ed4-1d02-4358-a0ce-6f4395cdca0e)

Progessbar:
![grafik](https://github.com/user-attachments/assets/27bf5c88-b12c-4650-9291-e2409ba4f650)

Details:
![grafik](https://github.com/user-attachments/assets/b94afcec-da19-4bd8-bc1e-14d0cdfd2b2c)

Output of more Details:
![grafik](https://github.com/user-attachments/assets/c9bab4f0-c138-4b8b-a716-538ac0cac846)

==> log for 10 Minutes and import for example in libreoffice:
![grafik](https://github.com/user-attachments/assets/6b1f4970-3689-4ec4-9e5b-f3dbeaef3270)





