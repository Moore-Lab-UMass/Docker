# Virtual Environments

## Singularity

This is the simpliest way to run the Docker container on a server cluster.

To pull a Docker container you can use:

`singularity pull docker://USER/REPO:TAGNAME`

> Currently you can use `docker://jordanvelezbomba/moore-lab:latest`

You can use `run`,`exec`,`shell`, and `instance start` to use the container.

<https://docs.sylabs.io/guides/3.1/user-guide/cli.html>

You can bind directories using `--bind`.

`singularity shell --bind /[LOCAL PATH]:/[CONTAINER PATH] REPO_TAGNAME.sif`

> This will bind the dir `/[LOCAL PATH]` from the server as `/[CONTAINER PATH]` (you can name this anything, probably best to just use `/data:/data` to keep scripts happy) inside the container. If you do not bind the data dir or give the `-writable` then the `/data` folder from the server will not be accessable.

<https://docs.sylabs.io/guides/3.1/user-guide/bind_paths_and_mounts.html>

## Docker

If you are on the server cluster than you must use Singularity to pull and run the docker container. Otherwise you can download docker for all other OS systems here:

<https://docs.docker.com/get-docker/>

Check installation

`docker -v`

## Docker repositories

`docker pull USER/REPO:TAGNAME`  
`docker push USER/REPO:TAGNAME`

<https://docs.docker.com/engine/reference/commandline/pull/>  
<https://docs.docker.com/engine/reference/commandline/push/>

## Build docker container

Build a container (must rebuild after any changes to the Dockerfile)

`docker build -f Dockerfile -t USER/REPO:TAGNAME .`

## Running docker container

Run bash inside the container

`docker run -ti USER/REPO:TAGNAME`

This is to mount a local directory to the container to share files between the container and local / server. You can use this if the scripts you are using and the data is in the same directory and any files produced from running the scripts will be put in the same folder. /root/data/ is where the local dir you input will be referenced.

`docker run -it --mount type=bind,src=[LOCAL PATH],dst=[CONTAINER PATH]`

`--mount` is the recommended way to mount a directory to a container, but `-volume` will not be deprecated and can still be used like so:

`docker run -v [LOCAL DIR]:/root/data/ -ti USER/REPO:TAGNAME`

For mounting a volume as read-only:

`docker run --read-only --mount type=volume,target=/icanwrite /icanwrite/here`

Connecting container to server / local machine.

`docker run -d --add-host host.docker.internal:host-gateway my-container:latest`

## Changing platform

In order for the Docker container to run it must be build for the platform it is going to be used on. If you have a Mac with an M1 chip this is essepcially true because it will build an `arm64` image that is not compatiable with linux. This current build is for linux/amd64. To change the platform it is being built for, change the platform in the FROM line in the Dockerfile `--platform=linux/amd64` to the required platform. For example if you want to run the same build on a mac with a M1 chip you can change it to `--platform=linux/arm64/8` then rebuild.

## Anaconda

### Prereq

If you just want to create the conda environment you only need to download `rpy.yml` and `install_packages_conda.R`.

## Installing miniconda on linux (silent)

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
&& /bin/bash Miniconda3-latest-Linux-x86_64.sh -b -p ~/miniconda3 \
&& rm -f Miniconda3-latest-Linux-x86_64.sh
```

If you are asked to start `conda init` say `yes`. If not call `conda init` to start it manually. Once it is done installing you will most likely need to restart the terminal for the changes to take effect.

## Installing on Mac with M1

Some of the packages will not run on an M1 so to get around this we must install rosetta using

`/usr/sbin/softwareupdate --install-rosetta --agree-to-license`

Then download the intel verion of miniconda instead of the arm64 version aka <https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh>

## Creating the conda environment

If you are on your local machine or linux server you can use this cmd to create the environment on it, just specify where rpy.yml is located. You must have miniconda installed to do this.

`conda env create -f rpy.yml`  
`conda env create -f /[DIR TO YML FILE]/rpy.yml`

<!-- If you are inside the container use this to create the environment.

`conda env create -f /src/rpy.yml` -->

## Activating and deactivating the conda environment

To activate the environment inside the container use `source` instead of `conda`. If inside your local machine or server distribution use 'conda'.

### Local machine / Server distribution

`conda activate rpy-macs`  
`conda deactivate`

### Container

`source activate rpy-macs`  
`source deactivate`

## Installing R packages

Call this cmd while the env is active to install all the r packages.

`Rscript install_packages_conda.R`

If you want to install additional packages, just make sure that the dir they are being installed to is `~/miniconda3/envs/rpy-macs/lib/R/library` by using the `destdir` parameter in the `install_packages()` command. For example:

`Rscript install_packages("ggplot2", destdir = "~/miniconda3/envs/rpy-macs/lib/R/library")`

Otherwise it will try to install it into the default R folder and will not be available in the environment. If you get a CRAN mirror error, set the options.

`options(repos = c(CRAN = "https://cloud.r-project.org"))`

### User guide

<https://docs.conda.io/projects/conda/en/latest/user-guide/index.html#>

### Cheatsheat

<https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf>

## Adding application, packages, and libraries

### Additional packages

Using pip3 or pip
`pip3 install [PACKAGE]`

or

`pip install [PACKAGE]`

In conda environment
`conda install [PACKAGE]`

To update installed pacakges (python)
`pip install --upgrade -r requirements.txt`

To update R packages. If there is a major R version change use set option `checkBuilt=TRUE`.
`R -e update.packages()`

> Data in Docker containers is not persistant, any packages installed while in the container will not be there after exiting. Anaconda will keep any packages installed while in the environment. All repositories and list of packages are you can install is linked below in resources.

### Adding applications and libraries

`apt-get install -y \`

In the Dockerfile you can add libraries and applications to install in the container under this line.

### Adding Python packages

`requirements.txt`

This text files contains a list of packages to install for python 3.7. When adding packages you might want to take note of the version just in case an update to a package doesn't work with a file you have written.

### Adding R packages

`install_packages.R` & `install_packages_conda.R`

This is an R script that contains the packages to install for R. To add more you can append additional package names to the `install_packages()` command into the `install_packages.R` for docker and `install_packages_conda.R` for conda.

### Adding packages to the conda environment

`rpy.yml`

This YML file is used to create the conda environment and contains a list of packages to install. It contains the applications, libraries, and python packages. This is used to create a conda environment with python 2 and macs.

## Resources

### Ubuntu repository

<https://packages.ubuntu.com>

<https://pkgs.org>

### R packages

<https://cran.r-project.org>

### Anaconda package repository

<https://anaconda.org/bioconda/repo>
