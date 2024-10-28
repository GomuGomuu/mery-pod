# 🏴‍☠️ One Piece Card Game:  Setup Guide (No Docker!) 🌊

Ahoy, nakama!  Ready to manage your One Piece Card Game collection with Merry and Olop Price Scraping? 

This script will set you up with both applications running outside Docker, using PostgreSQL as your database.

##  Get Started

1. **Gather Your Supplies:**

* **Git:**  Download the latest version of Git ([https://git-scm.com/](https://git-scm.com/))
* **Python:**  Install Python 3.12 ([https://www.python.org/](https://www.python.org/))
* **Tesseract OCR:** Install Tesseract OCR ([https://tesseract-ocr.github.io/](https://tesseract-ocr.github.io/))
* **A Strong Will:**  (Optional, but always helpful!)

2. **Clone the Repository:**

```bash
git clone https://github.com/GomuGomuu/mery-pod.git
```

3. **Set Up Your Treasure Map:**

* **Navigate to the repository:**
    ```bash
    cd mery-pod
    ```
* **Make the script executable:**
    ```bash
    chmod +x setup.sh
    ```

4. **Edit the `.env` Files:**

* **Merry:**
    * Navigate to the `merry` directory.
    * Open `.env` and set the following environment variables:
        * `POSTGRES_HOST` (usually `localhost`)
        * `POSTGRES_DB` (the name of your PostgreSQL database)
        * `POSTGRES_USER` (the name of your PostgreSQL user)
        * `POSTGRES_PASSWORD` (the password for your PostgreSQL user)
        * `DJANGO_SECRET_KEY` (set a strong, unique value)
* **Olop Price Scraping:**
    * Navigate to the `olop-price-scraping` directory.
    * Open `.env` and set the following environment variables:
        * `REDIS_PORT_HOST` (usually `localhost`)
        * `REDIS_PORT` (the Redis port, usually `6379`)
        * `REDIS_DB` (the Redis database number, usually `0`)
        * `SELENIUM_HOST` (usually `localhost`)
        * `OCR_PATH` (the path to your Tesseract OCR executable)

5. **Run the Setup Script:**

```bash
./setup.sh
```

**That's it!  Merry, Olop Price Scraping, Chromium, Flower, and PostgreSQL will start running in the background.**

##  Access the Applications

* **Merry:** Open your browser and visit `http://localhost:8000`
* **Olop Price Scraping API:** You can now use the API endpoints documented in the `olop-price-scraping` repository.
* **Chromium:**  Launch Chromium using the command: `chromium-browser` 
* **PostgreSQL:**  You can access the PostgreSQL database using tools like `psql` or `pgAdmin`.

##  Tips for the Journey:

* **Screen Magic:** Use `screen -r <session_name>` to reattach to the `merry` or `olop` screen session.
* **Troubleshooting:** Check your environment variables, install any missing dependencies, and consult the repositories' documentation for more guidance.
* **ChromeDriver:**  Ensure that you have the correct version of ChromeDriver for your Chromium installation.
