#!/bin/bash

# --- 1. Download Repositories (with Git Pull if existing) ---
echo "Downloading or updating repositories..."
if [ ! -d "merry" ]; then
  git clone https://github.com/GomuGomuu/merry.git
  echo "  merry repository cloned."
else
  cd merry
  git pull
  echo "  merry repository updated."
  cd ..
fi

if [ ! -d "olop-price-scraping" ]; then
  git clone https://github.com/GomuGomuu/olop-price-scraping.git
  echo "  olop-price-scraping repository cloned."
else
  cd olop-price-scraping
  git pull
  echo "  olop-price-scraping repository updated."
  cd ..
fi

# --- 2. Install Dependencies (General) ---
echo "Installing general dependencies..."

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
echo "  Installing Tesseract OCR..."
sudo apt-get update
if ! sudo apt-get install -y tesseract-ocr; then
  echo "  Error: Failed to install Tesseract OCR."
  exit 1
fi
echo "  Tesseract OCR installed."

# --- 3. Install and Configure PostgreSQL ---
echo "Installing and configuring PostgreSQL..."
sudo apt-get update
if ! sudo apt-get install -y postgresql postgresql-contrib; then
  echo "  Error: Failed to install PostgreSQL."
  exit 1
fi
echo "  PostgreSQL installed."

# --- 4. Configure Environment Variables (for PostgreSQL) ---
echo "Configuring PostgreSQL environment variables..."
# Merry (load .env first)
cd merry
cp .env.example .env
source .env

# Create PostgreSQL user and database
echo "  Creating PostgreSQL user and database..."
if ! sudo -u postgres psql -c "SELECT 1 FROM pg_user WHERE usename = '${POSTGRES_USER}';" &> /dev/null; then
  sudo -u postgres psql -c "CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';"
  echo "    PostgreSQL user created."
else
  echo "    PostgreSQL user already exists."
fi

if ! sudo -u postgres psql -c "SELECT 1 FROM pg_database WHERE datname = '${POSTGRES_DB}';" &> /dev/null; then
  sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};"
  echo "    PostgreSQL database created."
else
  echo "    PostgreSQL database already exists."
fi

# --- 5. Install and Configure Redis ---
echo "Installing and configuring Redis..."
sudo apt-get update
if ! sudo apt-get install -y redis-server; then
  echo "  Error: Failed to install Redis."
  exit 1
fi
echo "  Redis installed."

# Start Redis
echo "  Starting Redis service..."
sudo systemctl enable redis-server
if ! sudo systemctl start redis-server; then
  echo "  Error: Failed to start Redis service."
  exit 1
fi
echo "  Redis service started."

# --- 6. Download and Configure ChromeDriver ---
echo "Downloading and configuring ChromeDriver..."
# Get the Chromium version
CHROME_VERSION=$(chromium-browser --version | awk '{print $3}' | sed 's/\./_/g')
echo "  Detected Chromium version: ${CHROME_VERSION}"

# If the ChromeDriver for the detected version is not available 
#  or you want to manually specify the version
CHROME_DRIVER_VERSION=110_0_5462_79 # Replace with a compatible version 
wget -nv https://chromedriver.storage.googleapis.com/index.html
wget -nv https://chromedriver.storage.googleapis.com/${CHROME_DRIVER_VERSION}/chromedriver_linux64.zip
if [ $? -ne 0 ]; then
  echo "  Error: Failed to download ChromeDriver."
  exit 1
fi
echo "  ChromeDriver downloaded."

unzip chromedriver_linux64.zip
if [ $? -ne 0 ]; then
  echo "  Error: Failed to unzip ChromeDriver."
  exit 1
fi
echo "  ChromeDriver unzipped."

# Place ChromeDriver in your PATH
sudo mv chromedriver /usr/local/bin/
echo "  ChromeDriver moved to /usr/local/bin."

# --- 7. Install Flower ---
echo "Installing Flower..."
cd merry
if ! pip install flower; then
  echo "  Error: Failed to install Flower."
  exit 1
fi
echo "  Flower installed."

# --- 8.  Install Dependencies for Merry and Olop Price Scraping ---
echo "Installing dependencies for Merry and Olop Price Scraping..."
#  Using virtual environments
#  Merry
cd merry
python3 -m venv venv
source venv/bin/activate
if ! pip install -r requirements.txt; then
  echo "  Error: Failed to install dependencies for Merry."
  exit 1
fi
echo "  Dependencies for Merry installed."

#  Olop Price Scraping
cd ../olop-price-scraping
python3 -m venv venv
source venv/bin/activate
if ! pip install -r requirements.txt; then
  echo "  Error: Failed to install dependencies for Olop Price Scraping."
  exit 1
fi
echo "  Dependencies for Olop Price Scraping installed."

# --- 9.  Configure Environment Variables (for Redis and Selenium) ---
echo "Configuring environment variables for Redis and Selenium..."
# Olop Price Scraping (load .env first)
cd olop-price-scraping
cp .env.example .env
source .env

# --- 10.  Initialize Merry ---
echo "Initializing Merry..."
cd merry
if ! python manage.py migrate; then
  echo "  Error: Failed to migrate Merry database."
  exit 1
fi
echo "  Merry database migrated."

if ! python manage.py collectstatic --noinput; then
  echo "  Error: Failed to collect static files for Merry."
  exit 1
fi
echo "  Merry static files collected."

# --- 11. Install screen ---
echo "Installing screen..."
sudo apt-get update
if ! sudo apt-get install -y screen; then
  echo "  Error: Failed to install screen."
  exit 1
fi
echo "  Screen installed."

# --- 12. Start Services in Screen Sessions ---
echo "Starting services in screen sessions..."

# Merry (with Flower)
screen -S merry
source venv/bin/activate
if ! python manage.py runserver 0.0.0.0:8000; then
  echo "  Error: Failed to start Merry server."
  exit 1
fi

if ! python manage.py flower --address=0.0.0.0:5555; then
  echo "  Error: Failed to start Flower."
  exit 1
fi
screen -d -r merry
echo "  Merry and Flower started in background."

# Olop Price Scraping
cd ../olop-price-scraping
screen -S olop
source venv/bin/activate
if ! flask run --host=0.0.0.0; then
  echo "  Error: Failed to start Olop Price Scraping server."
  exit 1
fi
screen -d -r olop
echo "  Olop Price Scraping started in background."

echo "Setup Complete!"
echo "Merry is available at: http://localhost:8000"
echo "Flower is available at: http://localhost:5555"
echo "Chromium is available at: chromium-browser"