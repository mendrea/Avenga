# Use Robot Framework base image
FROM ppodgorsek/robot-framework:latest

# Set working directory
WORKDIR /opt/robotframework/tests

# Copy test suites and resources
COPY tests/ ./tests/
COPY Keywords/ ./Keywords/
COPY Settings.robot ./Settings.robot

# Switch to root to install Python dependencies
USER root
RUN pip install --no-cache-dir \
        robotframework-requests \
        robotframework-pabot \
        robotframework-jsonlibrary

# Run all tests in parallel by default
ENTRYPOINT ["pabot", "--processes", "5", "--output", "output.xml", "--report", "report.html", "--log", "log.html", "tests/"]
