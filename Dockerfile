FROM rocker/r-ver:4.5.2

# Setup Project Structure
WORKDIR /

# R package source files
COPY /src/R /src/R
COPY /src/NAMESPACE /src/NAMESPACE
COPY /src/DESCRIPTION /src/DESCRIPTION

# R dependencies
COPY renv.lock renv.lock

# Entrypoint file
COPY runtime.R runtime.R

# Install curl (used by pak)
RUN apt-get update && apt-get -y install --no-install-recommends curl 

# Install R dependencies via pak + renv
RUN R -e "options(renv.config.pak.enabled = TRUE, renv.config.ppm.url = 'https://packagemanager.posit.co/cran/2026-01-30')"
RUN R -e "install.packages('renv')"
RUN R -e "renv::restore(exclude = 'r.package')"
RUN R CMD INSTALL /src
RUN rm renv.lock

# Setup runtime
RUN chmod 755 -R runtime.R
ENTRYPOINT Rscript runtime.R
CMD ["calculate_lift"]
