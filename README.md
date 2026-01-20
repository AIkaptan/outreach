# Outreach Agent - Flask Application

A modern Flask-based web application for automated personalized email outreach, converted from an n8n workflow. This application uses AI to generate personalized outreach emails based on company data from Google Sheets and a knowledge base from Google Docs.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Project Structure](#project-structure)
- [Workflow Logic](#workflow-logic)
- [Development](#development)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)
- [Performance Tips](#performance-tips)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)

## Features

- 🎨 **Modern UI**: Beautiful, responsive design with Tailwind CSS
- 🤖 **AI-Powered**: Uses OpenAI GPT models (GPT-4o, GPT-4o-mini, GPT-4 Turbo, GPT-3.5 Turbo) to generate personalized emails
- 📊 **Google Sheets Integration**: Fetches company data from Google Sheets by row index
- 📚 **Knowledge Base**: Uses Google Docs as a knowledge base for email personalization
- 📧 **Email Sending**: Sends emails via SMTP with support for Gmail and custom SMTP servers
- ⚙️ **Easy Configuration**: Web-based configuration interface with real-time updates
- 🔍 **Connection Testing**: Test all API connections (Google Sheets, Google Docs, OpenAI, SMTP) from the dashboard
- 📦 **Batch Processing**: Process multiple rows at once with configurable start and end ranges
- ✅ **Email Validation**: Automatic validation of email addresses before processing
- 📈 **Execution Tracking**: Detailed results including sent, processed, skipped, and error counts
- 🧪 **Test Email Functionality**: Send test emails to verify SMTP configuration
- 🔐 **Flexible Authentication**: Support for both OAuth and Service Account authentication for Google services
- 🎯 **Personalized Content**: Generates unique subject lines and HTML email bodies for each recipient
- 📝 **Structured Output**: Uses JSON structured output for reliable AI responses

## Prerequisites

Before you begin, ensure you have the following:

- **Python 3.8 or higher** (Python 3.9+ recommended)
- **OpenAI API key** - Get one from [OpenAI Platform](https://platform.openai.com/api-keys)
- **Google Cloud Project** with the following APIs enabled:
  - Google Sheets API
  - Google Docs API
- **Google OAuth Credentials** or **Service Account** (see Configuration section)
- **SMTP Credentials** - Gmail App Password or custom SMTP server credentials
- **Google Sheets Document** - Contains company data with columns including `email_to_use`
- **Google Docs Document** - Contains your knowledge base for email personalization

## Installation

### Method 1: Using pip and requirements.txt (Recommended)

1. **Clone or navigate to the project directory:**
   ```bash
   cd outreach
   ```

2. **Create a virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

### Method 2: Using setup.py (For development)

1. **Navigate to the project directory:**
   ```bash
   cd outreach
   ```

2. **Create a virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install in development mode:**
   ```bash
   pip install -e .
   ```

   Or install in production mode:
   ```bash
   pip install .
   ```

### Post-Installation Setup

1. **Set up environment variables:**
   ```bash
   cp env.example .env
   ```
   
   Edit `.env` and fill in your credentials (see Configuration section for details):
   - `OPENAI_API_KEY`: Your OpenAI API key
   - `GOOGLE_SHEETS_DOCUMENT_ID`: Your Google Sheets document ID
   - `GOOGLE_SHEETS_SHEET_ID`: Sheet ID (usually 0 for the first sheet)
   - `GOOGLE_DOCS_DOCUMENT_ID`: Your Google Docs document ID (knowledge base)
   - `SMTP_*`: Your SMTP configuration
   - `SECRET_KEY`: Flask secret key (generate a secure random string for production)
   - `PORT`: Port number (default: 3000)

2. **Set up Google OAuth:**
   
   You have two options:
   
   **Option A: Using OAuth Flow (Recommended for first-time setup)**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Enable Google Sheets API and Google Docs API
   - Go to "Credentials" → "Create Credentials" → "OAuth client ID"
   - Select "Desktop app" as the application type
   - Download the credentials JSON file
   - Save it as `credentials.json` in the project root
   - Run a one-time OAuth flow to generate `token.json` (the application will prompt you on first run)
   
   **Option B: Using Service Account (Recommended for production)**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Navigate to "IAM & Admin" → "Service Accounts"
   - Click "Create Service Account"
   - Give it a name and description
   - Grant it the "Editor" role (or more specific roles for Sheets and Docs)
   - Click "Done"
   - Click on the created service account → "Keys" → "Add Key" → "Create new key"
   - Select JSON format and download
   - Share your Google Sheets and Google Docs with the service account email (found in the JSON file)
   - Set `GOOGLE_CREDENTIALS_JSON` in `.env` to the JSON content (as a single-line string) or save it as `service_account.json` and reference it

## Configuration

### Environment Variables

The application uses environment variables for configuration. Copy `env.example` to `.env` and fill in the following:

#### Required Variables

- `OPENAI_API_KEY`: Your OpenAI API key (get from [OpenAI Platform](https://platform.openai.com/api-keys))
- `GOOGLE_SHEETS_DOCUMENT_ID`: The ID from your Google Sheets URL (the long string between `/d/` and `/edit`)
- `GOOGLE_SHEETS_SHEET_ID`: The sheet ID (usually `0` for the first sheet, `1` for the second, etc.)
- `GOOGLE_DOCS_DOCUMENT_ID`: The ID from your Google Docs URL (the long string between `/d/` and `/edit`)
- `SMTP_HOST`: SMTP server hostname (e.g., `smtp.gmail.com`)
- `SMTP_PORT`: SMTP server port (usually `587` for TLS)
- `SMTP_USER`: SMTP username (usually your email address)
- `SMTP_PASSWORD`: SMTP password (for Gmail, use an App Password)
- `SMTP_FROM_EMAIL`: The email address to send from
- `SMTP_FROM_NAME`: The display name for sent emails

#### Optional Variables

- `SECRET_KEY`: Flask secret key for session management (default: `dev-secret-key-change-in-production`)
- `PORT`: Port number to run the application on (default: `3000`)
- `OPENAI_MODEL`: OpenAI model to use (default: `gpt-4o-mini`, options: `gpt-4o`, `gpt-4o-mini`, `gpt-4-turbo`, `gpt-3.5-turbo`)
- `GOOGLE_CREDENTIALS_JSON`: Service account JSON as a string (alternative to OAuth)
- `GOOGLE_TOKEN_FILE`: Path to OAuth token file (default: `token.json`)

### Google Sheets Data Format

Your Google Sheets should have the following columns (at minimum):
- `email_to_use`: The email address to send to (required)
- Additional columns can be used for personalization (e.g., `company_name`, `contact_name`, `industry`, etc.)

### Google Docs Knowledge Base

Your Google Docs document should contain information about:
- Industry-specific pain points
- Your product/service value propositions
- Common use cases
- Any other information that should be used to personalize emails

## Running the Application

1. **Make sure the port is free:**
   ```bash
   # Check if port 3000 is in use (or your configured PORT)
   lsof -i :3000
   
   # If in use, kill the process
   kill -9 <PID>
   
   # Or change PORT in .env
   PORT=3001
   ```

2. **Activate your virtual environment (if not already active):**
   ```bash
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Start the Flask application:**
   ```bash
   python app.py
   ```
   
   Or using the run script (if available):
   ```bash
   ./run.sh
   ```

4. **Open your browser:**
   Navigate to `http://localhost:3000` (or your configured port)

## Usage

### Web Interface

1. **Access the Dashboard:**
   - Open `http://localhost:3000` in your browser
   - You'll see the main dashboard with configuration options

2. **Configure the Application:**
   - Enter your Google Sheets Document ID
   - Enter your Google Sheets Sheet ID (usually 0)
   - Enter your Google Docs Document ID (knowledge base)
   - Configure SMTP settings:
     - SMTP Host (e.g., `smtp.gmail.com`)
     - SMTP Port (usually `587`)
     - SMTP User (your email)
     - SMTP Password (App Password for Gmail)
     - From Email
     - From Name
   - Select your OpenAI model (default: `gpt-4o-mini`)

3. **Test Connections:**
   - Click "Test All Connections" to verify all API connections
   - Or test individual services:
     - Google Sheets
     - Google Docs
     - OpenAI
     - SMTP
   - Fix any connection issues before proceeding

4. **Send Test Email:**
   - Use the "Test Email" feature to verify your SMTP configuration
   - Enter a recipient email address
   - Optionally customize subject and body
   - Click "Send Test Email"

5. **Execute Workflow:**
   - Enter the start row number (e.g., `1`)
   - Enter the end row number (e.g., `10`)
   - Click "Execute Workflow"
   - Monitor the results in real-time:
     - Processed rows count
     - Emails sent count
     - Skipped rows (invalid emails)
     - Errors (if any)

### API Usage

You can also interact with the application programmatically using the REST API (see API Documentation section).

### Example Workflow

1. Prepare your Google Sheets with company data
2. Prepare your Google Docs knowledge base
3. Configure all credentials in `.env` or via the web interface
4. Test all connections to ensure everything works
5. Start with a small batch (e.g., rows 1-5) to test
6. Review the generated emails
7. Scale up to larger batches once satisfied

## Project Structure

```
outreach/
├── app.py                      # Main Flask application
├── services/
│   ├── __init__.py
│   ├── outreach_agent.py      # Main workflow orchestration
│   ├── ai_service.py          # OpenAI integration
│   ├── email_service.py       # SMTP email sending
│   ├── google_sheets_service.py  # Google Sheets API
│   └── google_docs_service.py    # Google Docs API
├── templates/
│   └── index.html             # Main dashboard UI
├── requirements.txt           # Python dependencies
├── env.example               # Environment variables template
└── README.md                 # This file
```

## API Documentation

### Base URL

All API endpoints are prefixed with `/api` (except the main dashboard at `/`).

### Endpoints

#### `GET /`
Returns the main dashboard HTML page.

**Response:** HTML page

---

#### `GET /api/config`
Get the current configuration.

**Response:**
```json
{
  "google_sheets_document_id": "string",
  "google_sheets_sheet_id": "string",
  "google_docs_document_id": "string",
  "smtp_from_email": "string",
  "openai_model": "string"
}
```

**Example:**
```bash
curl http://localhost:3000/api/config
```

---

#### `POST /api/config`
Update configuration (currently returns success, but doesn't persist - use environment variables for persistence).

**Request Body:**
```json
{
  "google_sheets_document_id": "string",
  "google_sheets_sheet_id": "string",
  "google_docs_document_id": "string",
  "smtp_from_email": "string",
  "openai_model": "string"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Configuration updated"
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/api/config \
  -H "Content-Type: application/json" \
  -d '{
    "google_sheets_document_id": "your-sheets-id",
    "openai_model": "gpt-4o-mini"
  }'
```

---

#### `POST /api/execute`
Execute the outreach workflow for a range of rows.

**Request Body:**
```json
{
  "startRow": 1,
  "endRow": 10
}
```

**Response (Success):**
```json
{
  "status": "success",
  "message": "Processed 10 rows, sent 8 emails",
  "results": {
    "processed": 10,
    "sent": 8,
    "skipped": 2,
    "errors": []
  }
}
```

**Response (Error):**
```json
{
  "status": "error",
  "message": "Error message here"
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/api/execute \
  -H "Content-Type: application/json" \
  -d '{
    "startRow": 1,
    "endRow": 10
  }'
```

---

#### `POST /api/test-email`
Send a test email to verify SMTP configuration.

**Request Body:**
```json
{
  "to": "recipient@example.com",
  "subject": "Test Email",
  "body": "This is a test email"
}
```

**Response (Success):**
```json
{
  "status": "success",
  "message": "Test email sent"
}
```

**Response (Error):**
```json
{
  "status": "error",
  "message": "Error message here"
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/api/test-email \
  -H "Content-Type: application/json" \
  -d '{
    "to": "test@example.com",
    "subject": "Test",
    "body": "Test email body"
  }'
```

---

#### `POST /api/validate-connection`
Test API connections for one or all services.

**Request Body:**
```json
{
  "service": "all"
}
```

Or test a specific service:
```json
{
  "service": "google_sheets"
}
```

Valid service values: `all`, `google_sheets`, `google_docs`, `openai`, `smtp`

**Response:**
```json
{
  "google_sheets": {
    "status": "success"
  },
  "google_docs": {
    "status": "success"
  },
  "openai": {
    "status": "success"
  },
  "smtp": {
    "status": "success"
  }
}
```

Or if there's an error:
```json
{
  "google_sheets": {
    "status": "error",
    "message": "Error details here"
  }
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/api/validate-connection \
  -H "Content-Type: application/json" \
  -d '{"service": "all"}'
```

## Workflow Logic

The application replicates the n8n workflow with the following detailed steps:

1. **Row Selection**: User specifies start and end row numbers via the web interface or API
2. **Data Fetching**: For each row in the range:
   - Fetches company data from Google Sheets using the row index
   - Retrieves all columns for that row
3. **Email Validation**: 
   - Checks that `email_to_use` field exists
   - Validates that the email is not empty
   - Validates that the email contains the `@` symbol
   - If validation fails, the row is skipped and logged
4. **Knowledge Base Retrieval**: 
   - Fetches the knowledge base content from Google Docs
   - This content is used to provide context for AI personalization
5. **AI Generation**: 
   - Combines company data and knowledge base into a prompt
   - Sends the prompt to OpenAI with structured output format
   - Generates:
     - Personalized subject line (using various patterns)
     - HTML email body with industry-specific pain points
     - Professional email structure
6. **Email Sending**: 
   - Formats the email with proper headers
   - Sends via SMTP using configured credentials
   - Logs success or failure
7. **Result Tracking**: 
   - Tracks processed, sent, skipped, and error counts
   - Returns detailed results to the user

### Error Handling

- Invalid emails are skipped (not counted as errors)
- API failures are caught and logged
- The workflow continues processing other rows even if one fails
- All errors are included in the final results

## Development

### Setting Up Development Environment

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd outreach
   ```

2. **Create a virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

3. **Install in development mode:**
   ```bash
   pip install -e .
   ```

4. **Install development dependencies (if any):**
   ```bash
   pip install -r requirements-dev.txt  # If you create one
   ```

### Project Structure Details

```
outreach/
├── app.py                          # Main Flask application entry point
├── setup.py                        # Package setup configuration
├── requirements.txt                # Python dependencies
├── env.example                     # Environment variables template
├── LICENSE                         # MIT License
├── README.md                       # This file
├── services/                       # Core service modules
│   ├── __init__.py
│   ├── outreach_agent.py        # Main workflow orchestration logic
│   ├── ai_service.py              # OpenAI API integration
│   ├── email_service.py           # SMTP email sending service
│   ├── google_sheets_service.py   # Google Sheets API integration
│   └── google_docs_service.py     # Google Docs API integration
├── templates/                      # HTML templates
│   └── index.html                 # Main dashboard UI
└── .gitignore                      # Git ignore rules
```

### Code Style

- Follow PEP 8 Python style guide
- Use type hints where appropriate
- Add docstrings to all classes and functions
- Keep functions focused and single-purpose

### Adding New Features

1. Create a new service in `services/` if needed
2. Update `app.py` to add new routes
3. Update the frontend in `templates/index.html` if UI changes are needed
4. Update this README with new features
5. Test thoroughly before committing

## Deployment

### Production Considerations

1. **Security:**
   - Change `SECRET_KEY` to a strong random string
   - Never commit `.env` file to version control
   - Use environment variables or a secrets manager
   - Enable HTTPS in production
   - Use a production WSGI server (see below)

2. **WSGI Server:**
   For production, use a proper WSGI server instead of Flask's development server:
   
   **Using Gunicorn:**
   ```bash
   pip install gunicorn
   gunicorn -w 4 -b 0.0.0.0:3000 app:app
   ```
   
   **Using uWSGI:**
   ```bash
   pip install uwsgi
   uwsgi --http :3000 --wsgi-file app.py --callable app
   ```

3. **Process Management:**
   Use a process manager like systemd, supervisor, or PM2:
   
   **Example systemd service (`/etc/systemd/system/outreach-agent.service`):**
   ```ini
   [Unit]
   Description=Outreach Agent Flask Application
   After=network.target
   
   [Service]
   User=www-data
   WorkingDirectory=/path/to/outreach
   Environment="PATH=/path/to/outreach/venv/bin"
   ExecStart=/path/to/outreach/venv/bin/gunicorn -w 4 -b 0.0.0.0:3000 app:app
   
   [Install]
   WantedBy=multi-user.target
   ```

4. **Reverse Proxy:**
   Use Nginx or Apache as a reverse proxy:
   
   **Example Nginx configuration:**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       
       location / {
           proxy_pass http://127.0.0.1:3000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

5. **Environment Variables:**
   Set environment variables in your deployment environment or use a `.env` file (ensure it's not publicly accessible)

6. **Database (Optional):**
   For persistent configuration storage, consider adding a database (SQLite, PostgreSQL, etc.)

## Troubleshooting

### Port Already in Use
If your configured port is already in use:
```bash
# Find the process using the port (replace 3000 with your port)
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or change the port in .env
PORT=3001
```

### Google API Authentication Issues

**OAuth Issues:**
- Make sure you've enabled the required APIs in Google Cloud Console:
  - Google Sheets API
  - Google Docs API
- Verify your OAuth credentials are correct
- Check that `credentials.json` is in the project root
- Ensure the OAuth consent screen is configured
- Delete `token.json` and re-authenticate if needed

**Service Account Issues:**
- Verify the service account JSON is correctly formatted
- Check that your Google Sheets/Docs are shared with the service account email
- Ensure the service account has the necessary permissions
- Verify the `GOOGLE_CREDENTIALS_JSON` environment variable is set correctly

**Common Errors:**
- `403 Forbidden`: API not enabled or insufficient permissions
- `401 Unauthorized`: Invalid credentials or expired token
- `404 Not Found`: Incorrect document ID

### SMTP Issues

**Gmail:**
- Use an App Password instead of your regular password
  - Go to Google Account → Security → 2-Step Verification → App Passwords
  - Generate an app password for "Mail"
  - Use this password in `SMTP_PASSWORD`
- If 2-Step Verification is not enabled, enable it first
- Check that "Less secure app access" is disabled (use App Passwords instead)

**Other SMTP Servers:**
- Verify host, port, and credentials
- Check firewall settings
- Ensure TLS/STARTTLS is properly configured
- Test with a simple SMTP client first

**Common Errors:**
- `535 Authentication failed`: Wrong password or need App Password
- `Connection refused`: Wrong host/port or firewall blocking
- `Timeout`: Network issues or wrong SMTP server

### OpenAI API Issues

- Verify your API key is correct and active
- Check your OpenAI account has sufficient credits
- Ensure the model name is correct (e.g., `gpt-4o-mini`)
- Check rate limits if you're processing many requests
- Verify your API key has access to the selected model

### General Issues

**Import Errors:**
```bash
# Make sure all dependencies are installed
pip install -r requirements.txt

# Or reinstall in development mode
pip install -e .
```

**Module Not Found:**
- Ensure you're in the correct directory
- Activate your virtual environment
- Check that `services/__init__.py` exists

**Configuration Not Loading:**
- Verify `.env` file exists and is in the project root
- Check that environment variables are set correctly
- Restart the application after changing `.env`

## Security Considerations

1. **Environment Variables:**
   - Never commit `.env` file to version control
   - Use strong, unique values for `SECRET_KEY`
   - Rotate API keys regularly
   - Use secrets management services in production

2. **API Keys:**
   - Store API keys securely
   - Use different keys for development and production
   - Monitor API usage for unauthorized access

3. **Google Credentials:**
   - Keep service account keys secure
   - Limit service account permissions to minimum required
   - Regularly rotate credentials

4. **SMTP Credentials:**
   - Use App Passwords for Gmail
   - Never use your main account password
   - Consider using OAuth2 for email sending in production

5. **HTTPS:**
   - Always use HTTPS in production
   - Configure SSL certificates properly
   - Use secure cookies for sessions

6. **Input Validation:**
   - Validate all user inputs
   - Sanitize data before processing
   - Implement rate limiting for API endpoints

## Performance Tips

1. **Batch Processing:**
   - Process rows in reasonable batches (10-50 at a time)
   - Monitor API rate limits
   - Add delays between batches if needed

2. **Caching:**
   - Cache the Google Docs knowledge base (it doesn't change often)
   - Consider caching Google Sheets data for large datasets

3. **Async Processing:**
   - For large batches, consider using background tasks (Celery, RQ)
   - Use async/await for I/O operations

4. **Database:**
   - Store execution logs in a database for better tracking
   - Index frequently queried data

5. **Monitoring:**
   - Monitor API usage and costs
   - Track execution times
   - Set up alerts for failures

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests if applicable
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Contribution Guidelines

- Follow PEP 8 style guide
- Add docstrings to new functions/classes
- Update README.md if adding new features
- Test your changes before submitting

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review the [API Documentation](#api-documentation)
3. Open an issue on GitHub
4. Contact support@aikaptan.com

## Acknowledgments

- Built with [Flask](https://flask.palletsprojects.com/)
- AI powered by [OpenAI](https://openai.com/)
- Google integrations via [Google API Python Client](https://github.com/googleapis/google-api-python-client)
- UI styled with [Tailwind CSS](https://tailwindcss.com/)

---

**Made with ❤️ by AI Kaptan**

