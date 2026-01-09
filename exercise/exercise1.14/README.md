To download the project directory from repository:

git clone --no-checkout --filter=blob:none git@github.com:docker-hy/material-applications.git
cd material-applications
git sparse-checkout init --cone
git sparse-checkout set <directory-path>
git checkout main

Frontend:
docker run -d  -p 8080:8080 example-backend
 
Backend:
docker run -d  -p 5001:5001 example-frontend