#!/bin/bash

# --- 1. Download Repositories ---
git clone https://github.com/GomuGomuu/merry.git
git clone https://github.com/GomuGomuu/olop-price-scraping.git

# --- 2. Install Dependencies (General) ---

# Python (ensure it's installed; this is just a check)
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 not found. Please install it."
    exit 1
fi

# Pip (ensure it's installed; this is just a check)
if ! command -v pip &> /dev/null; then
    echo "Error: Pip not found. Please install it."
    exit 1
fi

# Tesseract OCR
sudo apt-get update
sudo apt-get install -y tesseract-ocr

# --- 3. Install and Configure PostgreSQL ---
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib

# --- 4. Configure Environment Variables (for PostgreSQL) ---
# Merry (load .env first)
cd merry
cp .env.example .env
source .env

# Create PostgreSQL user and database
sudo -u postgres psql -c "CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';"
sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};"

# --- 5. Install and Configure Redis ---
sudo apt-get update
sudo apt-get install -y redis-server

# Start Redis
sudo systemctl enable redis-server
sudo systemctl start redis-server

# --- 6. Install Chromium ---
sudo apt-get update
sudo apt-get install -y chromium-browser

# --- 7. Download and Configure ChromeDriver ---
# Get the Chromium version (replace the placeholder with your actual version)
CHROME_VERSION=$(chromium-browser --version | awk '{print $2}' | sed 's/\./_/g')
# Download the ChromeDriver (replace the placeholder with your actual version)
wget -nv https://chromedriver.storage.googleapis.com/index.html
wget -nv https://chromedriver.storage.googleapis.com/$(CHROME_VERSION)/chromedriver_linux64.zip
unzip chromedriver_linux64.zip

# Place ChromeDriver in your PATH (adjust if needed)
sudo mv chromedriver /usr/local/bin/

# --- 8. Install Flower ---
cd merry
pip install flower

# --- 9.  Install Dependencies for Merry and Olop Price Scraping ---
cd merry
pip install -r requirements.txt

cd ../olop-price-scraping
pip install -r requirements.txt

# --- 10. Configure Environment Variables (for Redis and Selenium) ---
# Olop Price Scraping (load .env first)
cd olop-price-scraping
source .env

# --- 11.  Initialize Merry ---
cd merry
python manage.py migrate
python manage.py collectstatic --noinput

# --- 12.  Start Services in Screen Sessions ---

# Merry (with Flower)
screen -S merry
python manage.py runserver
python manage.py flower --address=0.0.0.0:5555
screen -d -r merry

# Olop Price Scraping
cd ../olop-price-scraping
screen -S olop
flask run
screen -d -r olop

echo "Setup Complete!"
echo "Merry is available at: http://localhost:8000"
echo "Flower is available at: http://localhost:5555"
echo "Chromium is available at: chromium-browser"