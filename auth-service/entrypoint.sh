#!/bin/bash
set -e

# Aguardar pelo PostgreSQL
echo "Aguardando PostgreSQL..."
until PGPASSWORD=$SPRING_DATASOURCE_PASSWORD psql -h "postgres" -U "$SPRING_DATASOURCE_USERNAME" -d "distrischool" -c '\q'; do
  >&2 echo "PostgreSQL indisponível - aguardando"
  sleep 1
done

>&2 echo "PostgreSQL está pronto - iniciando aplicação"
exec java -jar /app/app.jar