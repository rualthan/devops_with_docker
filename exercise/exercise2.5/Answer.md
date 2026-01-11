git clone --no-checkout --filter=blob:none git@github.com:docker-hy/material-applications.git
cd material-applications
git sparse-checkout init --cone
git sparse-checkout set scaling-exercise
git checkout main
cd scaling-exercise
docker compose up -d --scale compute=3