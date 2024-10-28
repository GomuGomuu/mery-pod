#!/bin/bash

START_STEP=1 # Default starting step

# Check if a START_STEP is provided as an argument
if [ $# -ne 0 ]; then
    START_STEP=$1
    echo "Starting installation from step ${START_STEP}"
fi

# --- 1. Download Repositories (with Git Pull if existing) ---
if [ ${START_STEP} -le 1 ]; then
    echo "Step 1: Downloading or updating repositories..."
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
fi

# --- 2. Install Dependencies (General) ---
if [ ${START_STEP} -le 2 ]; then
    echo "Step 2: Installing dependencies (General)..."

    # Python (ensure it's installed; this is just a check)
    if ! command -v python3 &>/dev/null; then
        echo "Error: Python 3 not found. Please install it."
        exit 1
    fi

    # Pip (ensure it's installed; this is just a check)
    if ! command -v pip &>/dev/null; then
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
fi

# --- 3. Install and Configure PostgreSQL ---
if [ ${START_STEP} -le 3 ]; then
    echo "Step 3: Installing and configuring PostgreSQL..."
    sudo apt-get update
    if ! sudo apt-get install -y postgresql postgresql-contrib; then
        echo "  Error: Failed to install PostgreSQL."
        exit 1
    fi
    echo "  PostgreSQL installed."
fi

# --- 4. Configure Environment Variables (for PostgreSQL) ---
if [ ${START_STEP} -le 4 ]; then
    echo "Step 4: Configuring environment variables for PostgreSQL..."
    # Merry (load .env first)
    cd merry
    source .env

    # Create PostgreSQL user and database
    echo "  Creating PostgreSQL user and database..."
    if ! sudo -u postgres psql -c "SELECT 1 FROM pg_user WHERE usename = '${POSTGRES_USER}';" &>/dev/null; then
        sudo -u postgres psql -c "CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';"
        echo "    PostgreSQL user created."
    else
        echo "    PostgreSQL user already exists."
    fi

    if ! sudo -u postgres psql -c "SELECT 1 FROM pg_database WHERE datname = '${POSTGRES_DB}';" &>/dev/null; then
        sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};"
        echo "    PostgreSQL database created."
    else
        echo "    PostgreSQL database already exists."
    fi
    cd ..
fi

# --- 5. Install and Configure Redis ---
if [ ${START_STEP} -le 5 ]; then
    echo "Step 5: Installing and configuring Redis..."
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
fi

# --- 6. Install Chromium ---
if [ ${START_STEP} -le 6 ]; then
    echo "Step 6: Installing Chromium..."
    sudo apt-get update
    if ! sudo apt-get install -y chromium-browser; then
        echo "  Error: Failed to install Chromium."
        exit 1
    fi
    echo "  Chromium installed."
fi

# --- 7. Download and Configure ChromeDriver ---
if [ ${START_STEP} -le 7 ]; then
    echo "Step 7: Downloading and configuring ChromeDriver..."
    # Get the Chromium version
    CHROME_VERSION=$(chromium-browser --version | awk '{print $3}' | sed 's/\./_/g')
    echo "  Detected Chromium version: ${CHROME_VERSION}"

    CHROME_DRIVER_VERSION="110.0.5481.77" # Replace with a compatible version
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
fi

# --- 8. Install Flower ---
if [ ${START_STEP} -le 8 ]; then
    echo "Step 8: Installing Flower..."
    cd merry
    python3 -m venv venv
    source venv/bin/activate

    if ! pip install flower; then
        echo "  Error: Failed to install Flower."
        exit 1
    fi
    echo "  Flower installed."
    deactivate
    cd ..
fi

# --- 9. Install Dependencies for Merry and Olop Price Scraping ---
if [ ${START_STEP} -le 9 ]; then
    echo "Step 9: Installing dependencies for Merry and Olop Price Scraping..."

    # Merry
    cd merry
    python3 -m venv venv
    source venv/bin/activate

    if ! pip install poetry; then
        echo "  Error: Failed to install Poetry."
        exit 1
    fi
    echo "  Poetry installed."

    if ! poetry install --no-root -C src/config/; then
        echo "  Error: Failed to install dependencies for Merry."
        exit 1
    fi
    echo "  Dependencies for Merry installed."
    deactivate
    cd ..

    # Olop Price Scraping
    cd olop-price-scraping
    python3 -m venv venv
    source venv/bin/activate
    if ! pip install -r requirements.txt; then
        echo "  Error: Failed to install dependencies for Olop Price Scraping."
        exit 1
    fi
    echo "  Dependencies for Olop Price Scraping installed."
    deactivate
    cd ..
fi

# --- 10. Configure Environment Variables ---
if [ ${START_STEP} -le 10 ]; then
    echo "Step 10: Configuring environment variables for Redis and Selenium..."
    # Merge environment variables from both projects
    echo "Merging environment variables from olop-price-scraping and merry..."
    cat olop-price-scraping/linux.env merry/src/config/example.env >merged.env
    source merged.env
    echo "Environment variables configured."
fi

# --- 11. Initialize Merry ---
if [ ${START_STEP} -le 11 ]; then
    echo "Step 11: Initializing Merry..."
    cd merry
    source venv/bin/activate
    if ! python src/manage.py migrate; then
        echo "  Error: Failed to migrate Merry database."
        exit 1
    fi
    echo "  Merry database migrated."

    if ! python src/manage.py collectstatic --noinput; then
        echo "  Error: Failed to collect static files for Merry."
        exit 1
    fi
    echo "  Merry static files collected."
    deactivate
    cd ..
fi

# --- 12. Install screen ---
if [ ${START_STEP} -le 12 ]; then
    echo "Step 12: Installing screen..."
    sudo apt-get update
    if ! sudo apt-get install -y screen; then
        echo "  Error: Failed to install screen."
        exit 1
    fi
    echo "  Screen installed."
fi

# --- 13. Start Services in Screen Sessions ---
if [ ${START_STEP} -le 13 ]; then
    echo "Step 13: Starting services in screen sessions..."

    # Merry (with Flower)
    screen -dmS merry bash -c "cd merry && source venv/bin/activate && python src/manage.py runserver"

    # Flower
    screen -dmS flower bash -c "cd merry && source venv/bin/activate && flower"

    # Olop Price Scraping (with Celery)
    screen -dmS olop bash -c "cd olop-price-scraping && source venv/bin/activate && celery -A olop worker --loglevel=INFO"

    echo "  Services started in screen sessions."
fi

echo "Installation and setup completed successfully."
