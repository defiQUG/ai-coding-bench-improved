FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create directory for temporary PDF uploads
RUN mkdir -p /tmp/pdf-analyzer && \
    chmod 777 /tmp/pdf-analyzer

# Run as non-root user
RUN useradd -m appuser && \
    chown -R appuser:appuser /app /tmp/pdf-analyzer
USER appuser

# Expose the port the app runs on
EXPOSE 8001

# Command to run the application
CMD ["uvicorn", "comprehensive_pdf_analyzer:app", "--host", "0.0.0.0", "--port", "8001"] 