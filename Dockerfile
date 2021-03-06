FROM jupyter/scipy-notebook

###################
# R-NOTEBOOK COPY #
###################
USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    unixodbc \
    unixodbc-dev \
    r-cran-rodbc \
    gfortran \
    gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Fix for devtools https://github.com/conda-forge/r-devtools-feedstock/issues/4
RUN ln -s /bin/tar /bin/gtar

USER $NB_UID

# R packages
RUN conda install --quiet --yes \
    'r-base=4.0.3' \
    'r-caret=6.*' \
    'r-crayon=1.3*' \
    'r-devtools=2.3*' \
    'r-forecast=8.13*' \
    'r-hexbin=1.28*' \
    'r-htmltools=0.5*' \
    'r-htmlwidgets=1.5*' \
    'r-irkernel=1.1*' \
    'r-nycflights13=1.0*' \
    'r-randomforest=4.6*' \
    'r-rcurl=1.98*' \
    'r-rmarkdown=2.5*' \
    'r-rodbc=1.3*' \
    'r-rsqlite=2.2*' \
    'r-shiny=1.5*' \
    'r-tidyverse=1.3*' \
    'unixodbc=2.3.*' \
    'r-tidymodels=0.1*' \
    && \
    conda clean --all -f -y && \
    fix-permissions "${CONDA_DIR}"

# Install e1071 R package (dependency of the caret R package)
RUN conda install --quiet --yes r-e1071

# Done later to not rebuild all image on lib change
#
#RUN conda clean --all -f -y && \
#    fix-permissions $CONDA_DIR
#######################
# END R-NOTEBOOK COPY #
#######################

#######################
# CUSTOM R-NOTEBOOK   #
#######################
RUN conda install --quiet --yes -c bioconda \
    'bioconductor-dada2' \
    'bioconductor-phyloseq' \
    && \
    conda clean --all -f -y && \
    fix-permissions "${CONDA_DIR}"
#########################
# END CUSTOM R-NOTEBOOK #
#########################
USER root

COPY requirements.txt .
RUN  while read requirement; do conda install --quiet --yes $requirement; done < requirements.txt
RUN conda clean --all -f -y
RUN apt-get update && \
    apt-get install -y bwa rna-star mothur swarm spades
RUN jupyter labextension install jupyterlab-plotly
RUN jupyter labextension install @jupyter-voila/jupyterlab-preview
RUN jupyter labextension install @jupyterlab/hub-extension
# install packages not available with conda
RUN pip install streamlit requests bcbio-gff rpy2 voila ipyvuetify voila-vuetify ipysheet bqplot mothur-py mothulity line_profiler jupyterlab-git pipreqs openpyxl pysam
RUN jupyter lab build

# OUR STUFF HERE vv
#RUN conda install --yes -c conda-forge 'r-biocmanager=1.30.*'
# Disabled cause dependcies conflicts found by conda on 26-05-20
#RUN conda install --no-deps --yes -c bioconda 'bioconductor-edger=3.10'
#RUN conda install --no-deps --yes -c bioconda 'bioconductor-variancepartition'
#RUN conda install --no-deps --yes -c bioconda 'bioconductor-biocparallel'
# OUR STUFF HERE ^^

RUN conda clean --all -f -y
RUN fix-permissions $CONDA_DIR
USER $NB_UID
# Jupyter
EXPOSE 8888
# Streamlite
EXPOSE 8501
CMD ["jupyter", "lab"]


