To download the project directory from repository:

git clone --no-checkout --filter=blob:none <repository-url>
cd <repository-directory>
git sparse-checkout init --cone
git sparse-checkout set <directory-path>
git checkout main
