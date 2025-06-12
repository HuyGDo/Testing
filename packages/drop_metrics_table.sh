#!/bin/zsh

# Connection URL
CONN_URL="postgres://huygdo@localhost:5432/metrics?sslmode=disable"

# Drop materialized views (continuous aggregates)
VIEWS=$(psql "$CONN_URL" -t -c "SELECT matviewname FROM pg_matviews WHERE schemaname = 'public';")
for VIEW in ${(f)VIEWS}; do
    VIEW=$(echo $VIEW | xargs)
    if [[ -n "$VIEW" ]]; then
        echo "Dropping materialized view $VIEW..."
        psql "$CONN_URL" -c "DROP MATERIALIZED VIEW IF EXISTS public.\"$VIEW\" CASCADE;"
    fi
done

# Drop tables (including hypertables)
TABLES=$(psql "$CONN_URL" -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';")
for TABLE in ${(f)TABLES}; do
    TABLE=$(echo $TABLE | xargs)
    if [[ -n "$TABLE" ]]; then
        echo "Dropping table $TABLE..."
        psql "$CONN_URL" -c "DROP TABLE IF EXISTS public.\"$TABLE\" CASCADE;"
    fi
done

# Drop custom types (e.g., model_status ENUM)
TYPES=$(psql "$CONN_URL" -t -c "SELECT typname FROM pg_type WHERE typtype = 'e' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');")
for TYPE in ${(f)TYPES}; do
    TYPE=$(echo $TYPE | xargs)
    if [[ -n "$TYPE" ]]; then
        echo "Dropping type $TYPE..."
        psql "$CONN_URL" -c "DROP TYPE IF EXISTS public.\"$TYPE\" CASCADE;"
    fi
done

echo "All objects dropped."