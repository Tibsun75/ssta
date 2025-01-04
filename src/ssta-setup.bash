#!/bin/bash
# Dieses Skript wird beim ersten Start ausgeführt und weist den Benutzer darauf hin 
# die snap Berechtigungen zu setzen
set -e

SNAP_USER_DATA="$SNAP_USER_DATA/.ssta"
FIRST_RUN_MARKER="$SNAP_USER_DATA/.first_run_completed"

echo "Start setup für ssta..."

# Überprüfen, ob das Marker-File existiert
if [ ! -f "$FIRST_RUN_MARKER" ]; then
    echo "First start detected"

    # Erstelle das Verzeichnis für Benutzerdaten, falls es nicht existiert
    mkdir -p "$SNAP_USER_DATA"

    # Zeige die Befehle an um die Snap-Berechtigungen zu erlangen
    echo ""
    echo "Please open a new terminal and copy paste this commands:"
    echo "sudo snap connect ssta:network-observe"
    echo "sudo snap connect ssta:process-control"
    echo "sudo snap connect ssta:system-observe"
    echo "sudo snap connect ssta:system-trace"
    echo "sudo snap connect ssta:netlink-connector"
    echo ""
    echo "this commands allows snap to connect and observe network "
    echo "you have to do it , only the first one time "
    echo ""
    echo "Press any key if you finished." ; read -n 1 -s taste

    # Marker-Datei erstellen
    touch "$FIRST_RUN_MARKER"
    echo "Setup finished."
fi

# Starte das Hauptprogramm
exec "$@"
