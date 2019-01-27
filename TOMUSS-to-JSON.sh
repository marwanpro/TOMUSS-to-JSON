#!/bin/bash

TOMUSS_URL='https://tomusss.univ-lyon1.fr/'
CAS_Login_URL='https://cas.univ-lyon1.fr/cas/login'
CAS_Username='p1234567'
CAS_Password='bonjour123'

# Génère les cookies de connexions pour CAS et les exporte vers /tmp/cas.cookies
# Usage : loginCAS

function loginCAS() {
    TOKEN=$(\
        curl -sLo- -c /tmp/cas.cookies "$CAS_Login_URL" \
        | grep execution \
        | sed -E 's/.+value="(.+)" \/>/\1/' \
    )

    curl -sL "$CAS_Login_URL" \
        -o /dev/null \
        -b /tmp/cas.cookies \
        -c /tmp/cas.cookies \
        -d 'lt=' \
        -d '_eventId=submit' \
        -d 'submit=SE+CONNECTER' \
        -d 'rememberMe=true' \
        -d "execution=$TOKEN" \
        -d "username=$CAS_Username" \
        -d "password=$CAS_Password"
}

# Affiche le JSON formaté de TOMUSS.
# Arguments: 'Annee/Saison' pour obtenir un semestre. Retourne les metas sans arguements
# Usage : fetchTOMUSS '2019/Printemps'

function fetchTOMUSS() {
    if [ ! $# -eq 1 ]; then
        curl -sLo- "$TOMUSS_URL" -b /tmp/cas.cookies \
        | grep -A10 'display_suivi' \
        | grep -v 'script>' \
        | sed 's/,"Top");//' \
        | sed 's/display_update(//' \
        | tail -n 1 \
        | python -m json.tool
    else
        curl -sLo- "$TOMUSS_URL$SEM" -b /tmp/cas.cookies \
        | grep -A10 'display_suivi' \
        | grep -v 'script>' \
        | sed 's/,"Top");//' \
        | sed 's/display_update(//' \
        | sed 's/\\x3E/>/g' \
        | head -n 1 \
        | python -m json.tool
    fi
}
