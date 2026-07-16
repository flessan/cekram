# CekRAM Universal Docker Container (From docker/ directory)
FROM python:3.11-slim

LABEL maintainer="flessan <https://github.com/flessan/cekram>"

WORKDIR /app
COPY .. /app/
RUN pip install --no-cache-dir -e ./python[full]

EXPOSE 8080
ENTRYPOINT ["python3", "-m", "cekram.cli"]
CMD ["--lang", "en"]
