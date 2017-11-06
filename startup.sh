#!/bin/bash

set -x

function checaSeVariavelExiste() {
    if [ -z ${1+x} ]; then
        echo "Um parâmetro deve ser fornecido para 'checaSeVariavelExiste'"
    elif [ -z ${!1+x} ] && [ -z ${2+x} ] && [ -z ${!2+x} ]; then
        echo "Script de inicialização exige o parâmetro '${1}'"
        exit ${FALTA_PARAM}
    elif [ -z ${!1+x} ]; then
        eval "export ${1}=${2}"
        echo "(Usando valor padrão) ${1}=${2}"
    else
        echo "${1}=${!1}"
    fi
}

checaSeVariavelExiste 'NOMINATIMDBUSERNAME'
checaSeVariavelExiste 'NOMINATIMDBPASSWORD'
checaSeVariavelExiste 'NOMINATIMDBHOST' 
checaSeVariavelExiste 'NOMINATIMDBPORT' '5432'

sed -i "s/NOMINATIMDBUSERNAME/$NOMINATIMDBUSERNAME/g" /app/nominatim/settings/settings.php
sed -i "s/NOMINATIMDBPASSWORD/$NOMINATIMDBPASSWORD/g" /app/nominatim/settings/settings.php
sed -i "s/NOMINATIMDBHOST/$NOMINATIMDBHOST/g" /app/nominatim/settings/settings.php
sed -i "s/NOMINATIMDBPORT/$NOMINATIMDBPORT/g" /app/nominatim/settings/settings.php

/usr/sbin/apache2ctl -D FOREGROUND