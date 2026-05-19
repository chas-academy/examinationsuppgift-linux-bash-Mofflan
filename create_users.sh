#!/bin/bash

#Här checkar den om ID är inte NOT EQUAL 0. är den inte 0 så kommer den printa ut och sedan avsluta. Root är 0
if [ "$EUID" -ne 0 ]; then
    echo "NOT ROOT"
    exit 1
fi

#Här checkar den om det finns INGA data i parameter alltså EQUAL 0 = TOMT, då kommer programmet säga till med echo och avsluta.
if [ "$#" -eq 0 ]; then
    echo "Skriv minst en användare"
    exit 1
fi

#Skapar gruppen employees om den inte redan finns.
groupadd -f employees

#Loopar igenom varje username i parametrarna.
for USERNAME in "$@"; do

    #Lägger till användare -m hemkatalog automatiskt och sedan anger termial bash till användaren.
    useradd -m -s /bin/bash -g employees "$USERNAME"

    if [ $? -ne 0 ]; then
        echo "Skapa användaren $USERNAME FAILED"
        exit
    fi

    #Sätter lösenordet till samma som användarnamnet.
    chpasswd <<< "$USERNAME:$USERNAME"

    #Blocket skapar innehåller för welcome.text. etc/passwd innehåller användare på systemet.
    {
        printf "Welcome %s\n\n" "$USERNAME"
        printf "Existing users:\n"
        awk -F: '$3 >= 1000 && $1 != "'"$USERNAME"'" {print $1}' /etc/passwd
    } > "/home/$USERNAME/welcome.txt"

    #Skapar mapparna i användarens hemkatalog. -p ÄVEN om den finns så skapar det utan att krångla.
    mkdir -p "/home/$USERNAME/Documents" "/home/$USERNAME/Downloads" "/home/$USERNAME/Work"

    #Change owner till användare så inte root äger det när skripten körs.
    chown -R "$USERNAME:employees" "/home/$USERNAME"

    #Sätter rättigheter.
    chmod 700 "/home/$USERNAME/Documents" "/home/$USERNAME/Downloads" "/home/$USERNAME/Work"
    chmod 600 "/home/$USERNAME/welcome.txt"

done

echo "SCRIPT DONE"