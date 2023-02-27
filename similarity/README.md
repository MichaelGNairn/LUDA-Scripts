# testGCP
I have cloned this repo to GCP. 
There are a couple of things currently stored in this repo.
1. Some tests of basic functionality with Google Cloud Platform (GCP): python notebooks to read in data from BigQuery; do something, anything with it; plot dataframes and maps; write data to an output table etc.
2. It also stores exploratory work for a clustering project looking to identify similar local authorities in England based on the data held of LUDA from the the Subnational Indicators Explorer. This project is being done using the LUDA platform so it can double up as a test of how the platform work for a real data research project.

# Clustering code
For the clustering work, we are developing tools and methods. These can be applied to various projects which seek to cluster on baskets of metrics chosen. In this work, we have focussed on building tools first and will apply these to the most useful sets of metrics.
The clustering project uses a prototyping notebook (called productivity.ipnb), which is experimenting with some user-selected metrics related to productivity. This notebook contains exploratory analysis and builds plots of the clusters.
Using this as a guide, this code has been abstracted into functions, which are called in productivity-short.ipynb, which is a short script using the functions on the same sets of metrics. This serves as a test of the functions.

# Using Git with GCP
I found best results using HTTPS to connect to git. 
On GCP, go to git → clone a repositiory → copy/paste in the link (https://github.com/ONSdigital/LUDA).
The issue with this is that it asks for a username and personal access token (PAT). It says password or personal access token, but it throws an error if you give it a password (says support for this has expired), so it really wants a PAT!

# Personal access tokens
Personal access tokens can be created quite easily via github.
You need to use Settings → Developer settings (towards the bottom of the list) → Personal access tokens.
These are OK, the only problem being that you can only copy them immediately and can't then see them. They can however be regenerated at any time, so you can get a new one if need be.
The annoyance with HTTPS access is that you get asked for your credentials again when you push changes to the remote repo. This would be annoying if it was just your username and password every time, but it even worse with a PAT.

To store the credentials, add a cell to your notebook and run: 
!git config --global credential.helper store
This should only need to be done once per project, as it's being run in the git directory. After doing this, you will be asked for the username and PAT one more time and then those credentials will be stored and you shouldn't be asked again.

# Useful links
In this project, a useful reference to keep somewhere is colour maps: https://matplotlib.org/2.0.2/users/colormaps.html
