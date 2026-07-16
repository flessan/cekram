# CekRAM Universal Docker Container
FROM python:3.11-slim

LABEL maintainer="flessan <https://github.com/flessan/cekram>"
LABEL description="Universal Super RAM Monitor & Auto-Purge (Multi-Platform, ID/EN)"

WORKDIR /app

# Copy repo content
COPY . /app/

# Install python package
RUN pip install --no-cache-dir -e ./python[full]

# Expose web server port if used (`--server`)
EXPOSE 8080

ENTRYPOINT ["python3", "-m", "cekram.cli"]
CMD ["--lang", "id"]
