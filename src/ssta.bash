#!/bin/bash

# Überprüfen, ob dialog installiert ist
check_dialog_installed() {
	if ! command -v dialog &> /dev/null; then
		echo "$msg_error_dialog_not_installed"
    exit 1
	fi
}

# Analysiere die etablierten Verbindungen und gibt eine Liste zurück
get_established_connections() {
	ss -t -a | grep ESTAB | awk '{print $5}' | cut -d: -f1,2 | sort | uniq
}

# Führe whois aus und extrahiere den NetName und OrgName
get_whois_info() {
	local ip=$1
	local netname
	local orgname

	whois_output=$(whois $ip)

	# Extrahieren von netname und orgname direkt aus der WHOIS-Ausgabe
	netname=$(echo "$whois_output" | grep -i "netname" | head -n 1 | awk '{print $2}')
	orgname=$(echo "$whois_output" | grep -i "orgname" | head -n 1 | awk '{print $2}')

	# Falls keine Werte gefunden werden, setze sie auf den jeweiligen "Unbekannt"-Begriff
	netname=${netname:-$msg_unknown}
	orgname=${orgname:-$msg_unknown}

	echo "$netname|$orgname"
}

# Verarbeitet lsof-Ausgabe und gibt sie zurück
get_lsof_output() {
	local ip=$1
	local lsof_output=$(lsof -i @${ip} -sTCP:ESTABLISHED | awk 'NR > 1 {print $1, $2, substr($9, index($9, "->") + 2)}' | uniq)

	if [ -z "$lsof_output" ]; then
		echo "$msg_no_processes_found"
	else
    echo "$lsof_output"
	fi
}

# Zeigt eine Fortschrittsanzeige
show_progress() {
	local message=$1
	local percentage=$2
	echo $percentage | \
	dialog --no-lines --title "$title_connections" --gauge "$message" 6 60 0
}

# Zeigt eine Liste der Verbindungen in einem Dialog-Menü an und gibt die Auswahl zurück
select_connection() {
	local connection_list=("${!1}")
	dialog --no-lines --title "$title_connections" --no-cancel --menu "$msg_select_connection" 30 70 20 "${connection_list[@]}" 2>&1 >/dev/tty
}

# Zeigt eine Nachricht in einem Dialog-Fenster an
show_msgbox() {
	local title=$1
	local message=$2
	local height=$3
  
	dialog --no-lines --title "$title" --msgbox "$message" "$height" 100
}

# Auswahl der Sprache
select_language() {
	lang=$(dialog --no-lines --nocancel --backtitle "ssta network analyzer" --title "Please choose a language" --menu "" 11 35 3 \
    "Deutsch" "$msg_german" \
    "Türkçe" "$msg_turkish" \
    "English" "$msg_english" \
    "Espanol" "$msg_espanol" \
    "Hindi" "$msg_hindi" 2>&1 >/dev/tty)

	case $lang in
		Deutsch) set_german_texts ;;
		Türkçe) set_turkish_texts ;;
		English) set_english_texts ;;
		Espanol) set_spanish_texts ;;
		Hindi) set_hindi_texts ;;
		*) set_german_texts ;;
	esac
}

# Setzt deutsche Texte
set_german_texts() {
	title_error="Fehler"
	cancel_label="Abbrechen"
	msg_error_dialog_not_installed="Fehler: dialog ist nicht installiert. Bitte installiere dialog und versuche es erneut."
	msg_no_processes_found="Keine Prozesse gefunden die eine etablierte IP verwenden."
	msg_command_pid_connection="COMMAND PID VERBINDUNG"
	title_connections="Etablierte Verbindungen"
	msg_select_connection="Nr. IP:Port Netname Orgname"
	msg_analyze_connections="Analysiere mit ss -t -a, alle etablierten Verbindungen und erzeuge eine Liste:"
	msg_analyze_connection="Analysiere Verbindung $counter von "
	msg_new_query_prompt="Möchtest du eine neue Abfrage durchführen oder das Programm beenden?"
	msg_new_query="Neue Abfrage"
	msg_exit="Beenden"
	msg_program_terminated="Programm wird beendet."
	msg_unknown="Unbekannt"  
	msg_traffic="10 Minuten in der Datei Traffic.log protokollieren "
	msg_no_connections="Hilfe => Keine Verbindungen gefunden "
	msg_help="Entweder sind gerade keine etablierten Verbindungen vorhanden, oder sie sind offline."
	msg_help0="Oder in der Snap-Umgebung fehlen die Berechtigungen um den Netzwerkverkehr zu analysieren."
	msg_help1="Öffne ein Terminal und führe folgende Befehle aus um es nur für dieses Programm zu erlauben :"
	msg_help2="sudo snap connect ssta:network-observe"
	msg_help3="sudo snap connect ssta:process-control"
	msg_help4="sudo snap connect ssta:system-trace"
	msg_help5="sudo snap connect ssta:system-observe"
	msg_help6="sudo snap connect ssta:netlink-connector"
	command_="Befehl"
	pid_="Pid Nummer "
	connection_to="Verbindung zu"
	port_="Porttyp"
}

# Setzt türkische Texte
set_turkish_texts() {
	title_error="Hata"
	cancel_label="Iptal"
	msg_error_dialog_not_installed="Hata: dialog yüklü değil. Lütfen dialog'u yükleyin ve tekrar deneyin."
	msg_no_processes_found="IP kullanan hiç bir işlem bulunamadı."
	msg_command_pid_connection="KOMUT PID BAĞLANTI"
	title_connections="Kurulu Bağlantılar"
	msg_select_connection="Nr. IP:Port Netname Orgname"
	msg_analyze_connections="ss -t -a ile tüm kurulu bağlantıları analiz et ve bir liste oluştur:"
	msg_analyze_connection="Bağlantıyı analiz ediliyor"
	msg_new_query_prompt="Yeni bir sorgu yapmak mı istersiniz, yoksa programı kapatmak mı?"
	msg_new_query="Yeni Sorgu"
	msg_exit="Çıkış"
	msg_program_terminated="Program sona erdi."
	msg_unknown="Bilinmeyen"  # Türkisch für "Unbekannt"
	msg_traffic="10 dakika boyunca Traffic.log dosyasına kaydedilsin"
	msg_no_connections="Yardım => Bağlantı bulunamadı"
	msg_help="Ya aktif bağlantılar kurulmamış ya da çevrimdışısınız."
	msg_help0="Ya da Snap ortamında ağ trafiğini analiz etmek için gerekli izinler eksik."
	msg_help1="Bu program için yalnızca izin vermek amacıyla bir terminal açın ve aşağıdaki komutları çalıştırın:"
	msg_help2="sudo snap connect ssta:network-observe"
	msg_help3="sudo snap connect ssta:process-control"
	msg_help4="sudo snap connect ssta:system-trace"
	msg_help5="sudo snap connect ssta:system-observe"
	msg_help6="sudo snap connect ssta:netlink-connector"
	command_="Komut"
	pid_="Pid Numarası"
	connection_to="Bağlantı"
	port_="Port türü"
}

# Setzt englische Texte
set_english_texts() {
	title_error="Error"
	cancel_label="Cancel"
	msg_error_dialog_not_installed="Error: dialog is not installed. Please install dialog and try again."
	msg_no_processes_found="No processes found that using a established IP."
	msg_command_pid_connection="COMMAND PID CONNECTION"
	title_connections="Established Connections"
	msg_select_connection="No. IP:Port Netname Orgname"
	msg_analyze_connections="Analyze all established connections with ss -t -a and generate a list:"
	msg_analyze_connection="Analyzing connections"
	msg_new_query_prompt="Do you want to perform a new query or exit the program?"
	msg_new_query="New Query"
	msg_exit="Exit"
	msg_program_terminated="Program terminated."
	msg_unknown="Unknown"
	msg_no_connections="Help => No connections found"
	msg_traffic="Log traffic in the Traffic.log file for next 10 minutes"
	msg_no_connections="Help => No connections found"
	msg_help="Either no active connections are established, or you are offline."
	msg_help0="Or the permissions in the Snap environment are missing to analyze network traffic."
	msg_help1="Open a terminal and execute the following commands to allow it only for this program:"
	msg_help2="sudo snap connect ssta:network-observe"
	msg_help3="sudo snap connect ssta:process-control"
	msg_help4="sudo snap connect ssta:system-trace"
	msg_help5="sudo snap connect ssta:system-observe"
	msg_help6="sudo snap connect ssta:netlink-connector"
	command_="Command"
	pid_="Pid Number"
	connection_to="Connection to"
	port_="Port Type"
}

# Setzt spanische Texte
set_spanish_texts() {
	title_error="Error"
	cancel_label="Cancelar"
	msg_error_dialog_not_installed="Error: dialog no está instalado. Por favor, instala dialog e intenta nuevamente."
	msg_no_processes_found="No se encontraron procesos que usen esta IP."
	msg_command_pid_connection="COMANDO PID CONEXIÓN"
	title_connections="Conexiones establecidas"
	msg_select_connection="Nº IP:Puerto Nombre de red Nombre de la organización"
	msg_analyze_connections="Analiza con ss -t -a todas las conexiones establecidas y genera una lista:"
	msg_analyze_connection="Analizando la conexión $counter"
	msg_new_query_prompt="¿Quieres realizar una nueva consulta o salir del programa?"
	msg_new_query="Nueva consulta"
	msg_exit="Salir"
	msg_program_terminated="El programa se está cerrando"
	msg_unknown="Desconocido"# Spanisch für "Unbekannt"
	msg_traffic="Guarde en Traffic.log durante los próximos 10 minutos"
	msg_no_connections="Ayuda => No se encontraron conexiones"
	msg_help="O no hay conexiones establecidas actualmente, o están desconectadas."
	msg_help0="O faltan permisos en el entorno Snap para analizar el tráfico de red."
	msg_help1="Abre una terminal y ejecuta los siguientes comandos para permitirlo solo para este programa:"
	msg_help2="sudo snap connect ssta:network-observe"
	msg_help3="sudo snap connect ssta:process-control"
	msg_help4="sudo snap connect ssta:system-trace"
	msg_help5="sudo snap connect ssta:system-observe"
	msg_help6="sudo snap connect ssta:netlink-connector"
	command_="Comando"
	pid_="Número de Pid"
	connection_to="Conexión a"
	port_="tipo de puerto"
}

# Setzt indische Texte
set_hindi_texts() {
	title_error="त्रुटि"
	cancel_label="रद्द करें"
	msg_error_dialog_not_installed="त्रुटि: डायलॉग स्थापित नहीं है। कृपया डायलॉग स्थापित करें और पुनः प्रयास करें।"
	msg_no_processes_found="कोई प्रक्रियाएँ नहीं मिलीं जो इस IP का उपयोग कर रही हों।"
	msg_command_pid_connection="कमांड PID कनेक्शन"
	title_connections="स्थापित कनेक्शन"
	msg_select_connection="नं. IP:पोर्ट नेटवर्क नाम संगठन नाम"
	msg_analyze_connections="ss -t -a के साथ सभी स्थापित कनेक्शनों का विश्लेषण करें और एक सूची बनाएं:"
	msg_analyze_connection="कनेक्शन का विश्लेषण कर रहे हैं $counter"
	msg_new_query_prompt="क्या आप एक नई क्वेरी करना चाहते हैं या प्रोग्राम को समाप्त करना चाहते हैं?"
	msg_new_query="नई क्वेरी"
	msg_exit="बंद करें"
	msg_program_terminated="कार्यक्रम समाप्त हो रहा है।"
	msg_unknown="अज्ञात"  # Hindi für "Unbekannt"
	msg_traffic='अगले 10 मिनट के लिए ट्रैफिक.लॉग में सेव करें'
	msg_no_connections="सहायता => कोई कनेक्शन नहीं मिला"
	msg_help="या तो वर्तमान में कोई स्थापित कनेक्शन नहीं हैं, या आप ऑफ़लाइन हैं।"
	msg_help0="या Snap पर्यावरण में नेटवर्क ट्रैफ़िक का विश्लेषण करने की अनुमति नहीं है।"
	msg_help1="एक टर्मिनल खोलें और केवल इस प्रोग्राम के लिए अनुमति देने के लिए निम्नलिखित कमांड चलाएँ:"
	msg_help2="sudo snap connect ssta:network-observe"
	msg_help3="sudo snap connect ssta:process-control"
	msg_help4="sudo snap connect ssta:system-trace"
	msg_help5="sudo snap connect ssta:system-observe"
	msg_help6="sudo snap connect ssta:netlink-connector"
	command_="कमान्ड"
	pid_="पीआईडी नंबर"
	connection_to="कनेक्शन से"
	port_="पोर्ट प्रकार"
}


# Funktion, um den Traffic für 10 Minuten zu loggen
log_traffic_for_10_minutes() {
	start_time=$(date +%s)
	end_time=$((start_time + 600)) # 10 Minuten in Sekunden
	csv_file="Traffic.log_$(date +%Y%m%d_%H%M%S).csv"

	echo "Datum:Zeit:IP;Port;Netname;Orgname;lsof command" > "$csv_file"

# Starten der Fortschrittsanzeige
	progress_percentage=0
	dialog --no-lines --title "$title_connections" --gauge "$msg_traffic" 7 60 0 &

	while [ $(date +%s) -lt $end_time ]; do
		connections=$(get_established_connections)

	for conn in $connections; do
		ip=$(echo $conn | cut -d: -f1)
		port=$(echo $conn | cut -d: -f2)
		whois_info=$(get_whois_info $ip)
		netname=$(echo $whois_info | cut -d'|' -f1)
		orgname=$(echo $whois_info | cut -d'|' -f2)
		lsof_output=$(get_lsof_output $ip)

		# Datum:Zeit:IP;Port;Netname;Orgname;lsof command
		timestamp=$(date '+%Y-%m-%d:%H:%M:%S')
		# Prozessname anstelle von COMMAND ausgeben
		process_name=$(echo "$lsof_output" | awk '{print $1}' | head -n 1) 
		echo "$timestamp;$ip:$port;$netname;$orgname;$process_name" >> "$csv_file"
	done

	# Berechnung des Fortschritts in Prozent
    progress_percentage=$(( ( $(date +%s) - $start_time ) * 100 / 600 ))
    # Update der Fortschrittsanzeige
    echo $progress_percentage | dialog --no-lines --title "$title_connections" --gauge "$msg_traffic" 7 60
    sleep 10 # Alle 10 Sekunden ein Update
	done 
}

help_msg() {
	full_msg="$msg_help\n$msg_help0\n$msg_help1\n\n$msg_help2\n$msg_help3\n$msg_help4\n$msg_help5\n$msg_help6"
	show_msgbox "$title_error" "$full_msg" 14
	clear
	echo $msg_help
	echo $msg_help0
	echo $msg_help1
	echo ""
	echo $msg_help2
	echo $msg_help3
	echo $msg_help4
	echo $msg_help5
	echo $msg_help6
}

# Hauptlogik
main() {
# Sprache auswählen
	select_language

	check_dialog_installed

	while true; do
		# ss -t -a ausführen und Verbindungen filtern
		connections=$(get_established_connections)

		if [ -z "$connections" ]; then
			echo "$msg_no_processes_found"
			show_msgbox "$title_error" "$msg_no_processes_found" 5
			help_msg
			exit 1
		fi

	# Alle Verbindungen analysieren
	echo "$msg_analyze_connections"

	connection_list=()
	counter=1
	declare -A ip_map
	declare -A port_map
	declare -A netname_map
	declare -A orgname_map

	# Erstelle eine Liste der Verbindungen
	for conn in $connections; do
		ip=$(echo $conn | cut -d: -f1)
		port=$(echo $conn | cut -d: -f2)

		# Zeige den Fortschritt an und aktualisiere die Anzeige mit der aktuellen Verbindung
		progress_message="$msg_analyze_connection $counter von $(echo "$connections" | wc -w): $ip:$port"
		show_progress "$progress_message" $((counter * 100 / $(echo "$connections" | wc -w)))

		# Holen der Whois-Informationen
		whois_info=$(get_whois_info $ip)
		netname=$(echo $whois_info | cut -d'|' -f1)
		orgname=$(echo $whois_info | cut -d'|' -f2)

		# Formatierte Strings mit printf
		formatted_ip=$(printf "%-15s" "$ip")
		formatted_port=$(printf "%-5s" "$port")
		formatted_netname=$(printf "%-20s" "$netname")
		formatted_orgname=$(printf "%-20s" "$orgname")

		# Füge die formatierten Werte in die Liste für dialog hinzu
		connection_list+=("$counter" "$formatted_ip:$formatted_port $formatted_netname $formatted_orgname")
		ip_map[$counter]=$ip
		port_map[$counter]=$port
		netname_map[$counter]=$netname
		orgname_map[$counter]=$orgname
		((counter++))
	done

	# Auswahl der Verbindung
	selected_connection=$(select_connection connection_list[@])

	if [ -z "$selected_connection" ]; then
		echo "$msg_no_processes_found"
		help_msg
		exit 1
	fi

	# Die IP-Adresse und der Port der ausgewählten Verbindung ermitteln
	selected_ip=${ip_map[$selected_connection]}
	selected_port=${port_map[$selected_connection]}
	selected_netname=${netname_map[$selected_connection]}
	selected_orgname=${orgname_map[$selected_connection]}

	# Ausgabe mit whois der IP
	echo "Verbindung mit IP $selected_ip:$selected_port wird überprüft..."
	whois $selected_ip

	# Führe lsof aus, um das verwendete Programm zu finden
	lsof_output=$(get_lsof_output $selected_ip)

	# Zeige die lsof-Ausgabe direkt in einem Dialog-Fenster an
	header="$command_, $pid_, $connection_to, $port_"
	show_msgbox "$title_connections" "$header\n\n$lsof_output" 8
    
	# Auswahl 
	log_choice=$(dialog --no-lines --nocancel --title "$title_connections" --menu "$msg_new_query_prompt" 11 80 3 \
		"$msg_new_query" ""\
		"$msg_traffic" "" \
		"$msg_no_connections" "" \
		"$msg_exit" "" 2>&1 >/dev/tty)

	case $log_choice in
		"$msg_new_query") continue ;;
		"$msg_exit") 
			echo "$msg_program_terminated"
			exit 0
			;;
		"$msg_traffic") log_traffic_for_10_minutes
			exit 0
			;;
		"$msg_no_connections") help_msg
		exit 0
		;;
	esac
done
}

# Starte das Hauptprogramm
main

# Ende 
