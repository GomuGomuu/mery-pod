# 🏴‍☠️ One Piece Card Game: Setup Guide (No Docker!) 🌊

Ahoy, nakama! Ready to manage your One Piece Card Game collection with Merry and Olop Price Scraping?

This script will set you up with both applications running outside Docker, using PostgreSQL as your database. It was initially designed to be deployed on a Raspberry Pi 3B+.

## Get Started

1. **Gather Your Supplies:**

   * **Git:** Download the latest version of Git ([https://git-scm.com/](https://git-scm.com/))
   * **Python:** Install Python 3.12 ([https://www.python.org/](https://www.python.org/))
   * **Tesseract OCR:** Install Tesseract OCR ([https://tesseract-ocr.github.io/](https://tesseract-ocr.github.io/))
   * **A Strong Will:** (Optional, but always helpful!)

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

   To run the setup script, follow these instructions:

   1. **Make the script executable** (if you haven't done so already):

      ```bash
      chmod +x setup.sh
      ```

   2. **Run the setup script:**

      You can start the installation process by running the script from the command line. You can specify a starting step if needed.

      * To run the entire setup from the beginning:

        ```bash
        ./setup.sh
        ```

      * To start the setup from a specific step, provide the step number as an argument. For example, to start from step 5 (Redis installation):

        ```bash
        ./setup.sh 5
        ```

   The script performs the following steps:

   - **Step 1:** Clones the necessary repositories (`merry` and `olop-price-scraping`) or updates them if they already exist.
   - **Step 2:** Installs essential dependencies, including Python, Pip, and Tesseract OCR.
   - **Step 3:** Installs and configures PostgreSQL.
   - **Step 4:** Configures environment variables for PostgreSQL and creates the database and user.
   - **Step 5:** Installs and configures Redis.
   - **Step 6:** Installs Chromium for the scraping process.
   - **Step 7:** Downloads and configures ChromeDriver for web automation.
   - **Step 8:** Installs Flower, a real-time monitoring tool for Celery.
   - **Step 9:** Installs additional dependencies for both Merry and Olop Price Scraping.
   - **Step 10:** Configures environment variables for Redis and Selenium.
   - **Step 11:** Initializes the Merry application and applies database migrations.
   - **Step 12:** Installs Screen, allowing you to run the services in the background.
   - **Step 13:** Starts the Merry and Olop services in separate screen sessions, enabling you to manage them easily.

6. **Access the Applications:**

   * **Merry:** Open your browser and go to `http://localhost:8000`
   * **Olop Price Scraping API:** Access the API endpoints documented in the `olop-price-scraping` repository.
   * **Chromium:** Launch Chromium using the command: `chromium-browser`
   * **PostgreSQL:** You can access the PostgreSQL database using tools like `psql` or `pgAdmin`.

## Using Screen

`screen` is a terminal multiplexer that allows you to run multiple terminal sessions within a single window. This is particularly useful for running long-running processes without keeping your terminal open.

### Basic Screen Commands

1. **Start a New Screen Session:**
   To start a new screen session, use the following command:
   ```bash
   screen -S <session_name>
   ```
   Replace `<session_name>` with a name of your choice. For example:
   ```bash
   screen -S merry
   ```

2. **Detach from a Screen Session:**
   To detach from the session (leave it running in the background), press:
   ```
   Ctrl + A, then D
   ```

3. **List Active Screen Sessions:**
   To see all running screen sessions, type:
   ```bash
   screen -ls
   ```

4. **Reattach to a Screen Session:**
   To reattach to a detached session, use:
   ```bash
   screen -r <session_name>
   ```
   For example:
   ```bash
   screen -r merry
   ```

5. **Exit a Screen Session:**
   To exit a session completely, type `exit` within the screen session, or press `Ctrl + D`.

### Example Workflow

Here's an example of how to start and manage your services using `screen`:

1. **Start Merry:**
   ```bash
   screen -S merry bash -c "cd merry && source venv/bin/activate && python manage.py runserver"
   ```

2. **Start Flower:**
   ```bash
   screen -S flower bash -c "cd merry && source venv/bin/activate && flower"
   ```

3. **Start Olop Price Scraping:**
   ```bash
   screen -S olop bash -c "cd olop-price-scraping && source venv/bin/activate && celery -A olop worker --loglevel=INFO"
   ```

4. **Detach from any session:**
   Press `Ctrl + A`, then `D`.

5. **Reattach to the Merry session:**
   ```bash
   screen -r merry
   ```

## Tips for the Journey:

* **Screen Magic:** Use `screen -r <session_name>` to reattach to the `merry`, `flower`, or `olop` screen sessions.
* **Troubleshooting:** Check your environment variables, install any missing dependencies, and consult the repositories' documentation for more guidance.
* **ChromeDriver:** Ensure that you have the correct version of ChromeDriver for your Chromium installation.

## Usage

[Explain how to use the project, how to run the scraping process, how to access the results, etc. Be specific and provide examples.]

## Contributing

Ahoy! Want to join our crew? Contributions are most welcome! Please see the [CONTRIBUTING.md](CONTRIBUTING.md) file for details on how to contribute to this project.

## License

This project is licensed under the [MIT](LICENSE) License - see the [LICENSE](LICENSE) file for details.
