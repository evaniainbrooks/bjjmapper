until wget --delete-after bjjmapper.com; do
  echo "HTTP still down, sleeping 1 second";
  sleep 1;
done
