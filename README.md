# gpuideal
# THIS IS AN EXPERIMENTAL FORK OF GPUIDEAL. PLEASE SEE https://github.com/JeffreyBLewis/gpuideal FOR THE LATEST VERSION.

## News
We pushed a new version of the code on July 11, 2019. I have confirmed the EC2 install and run instructions below function as of August 19, 2019.  Please let me know if you run into trouble.  Several users have asked about installing this package under Windows.  At the moment, installing under windows will require you to build the CUDA source for the shared library manually or writing your own Makefile or configure script. If you write a build script for Windows please make a pull request.  **While this code has been tested extensively, this package remains experimental**.

## Install
Requires CUDA support to estimate [Clinton, Jackman, and River's (2004)](https://www.cs.princeton.edu/courses/archive/fall09/cos597A/papers/ClintonJackmanRivers2004.pdf) IDEAL model.  

For more information about `gpuideal` and what it does, see the white paper: http://www.ctausanovitch.com/gpuideal.pdf

This package only supports NVIDIA GPUs. To install the package, you must first install Nvidia's CUDA Toolkit available from

http://developer.nvidia.com/cuda-downloads

Install `gpuideal` with 

```{r}
> devtools::install_github("jeffreyblewis/gpuideal")
```

## Use

Fit to simulated data:

```{r}
> library(gpuideal)
> test_ideal(nrc=200, nmem=100, samples=50000, thin=10)
```

Fit all rollcalls from the 114th US Senate:

```{r}
> library(gpuideal)
> library(coda)
> library(pscl)
> rcdat <- readKH("https://voteview.com/static/data/out/votes/S114_votes.ord")
> res <- gpu_ideal(rcdat, samples=5000, burnin=5000, thin=5,
                  abprior=matrix(c(25,0,0,25),2,2),
                  x = ifelse(rcdat$legis.data$party=="D",-0.5, 0.5))
> scale_dir <- as.integer(rcdat$legis.data$party=="R") 
> rr <- rescaleIdeal(res, scale_dir)  
> summary(rr)[[1]][1:length(scale_dir),] 
```

Fit simulated data using EM estimation algorithm

```{r}
> library(tidyverse)
> rc <- 65
> mem <- 5000
> dat <- simrc(nrc=rc, nmem=mem)
> dat$votes[matrix(runif(rc*mem)>0.6, rc, mem)] <- 0  # Add some abstentions !
> em_res <- gpu_em_ideal(dat, steps=10000, thin=100,
                       xprior=1,
                       abprior=matrix(c(25,0,0,25),2,2),
                       x = rnorm(length(dat$x)),
                       blocks=256)
```

Estimate two-dimensional ideal point model via EM:

```{r}
> library(gpuideal)
> rc <- 5000
> mem <- 200
> dat <- simrc2d(nrc=rc, nmem=mem)
> dat$votes[matrix(runif(rc*mem)>0.6, rc, mem)] <- 0
> em_res <- gpu_em_ideal2d(dat, steps=500, thin=1,
                xprior=1,
                abprior=diag(rep(25,3)),
		blocks=256)
```

## Using with Amazon Web Services EC2

This package requires NVIDIA GPU support and NVIDIA's CUDA framework.  One way to access this is through an Amazon Web Services' EC2.   A `Deep Learning AMI` on a `p2.xlarge` instance provides a powerful NVIDIA GPU and CUDA support.  We have tested extensively on this setup.  Install `R` (and `Rstudio` if you want) and you are under way!

Here is a step-by-step guide to getting `gpuideal` running on an AWS EC2. 

1. Establish an account/login to AWS at https://aws.amazon.com/console/.

2. Select Services -> Compute -> EC2

3. Launch Instance

4. Scroll down and choose a "Deep Learning AMI"
   i.e. `(Amazon Linux) Version 12.0 - ami-de752aa6`

5. Select the instance that has `p2.xlarge` in the second column

6. Configure if desired, or simply hit "Review and Launch"

7. Launch

8. Follow the prompts to download a private key (`ANY_NAME.pem`)

9. Go to Services -> Compute -> EC2

10. click on "instances" on the left panel
    this will show you the ip address for the instance that you have created

11. On a Mac or Linux machine, the server can be accessed through the terminal as follows:

```
> ssh -i [PATH TO YOUR PRIVATE KEY] [USERNAME]@[IP ADDRESS]
```

   username varies by platform. For an Amazon Linux instance it is ec2-user.
    for more info on accessing linux instances, see: 
    https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html
    (you may need to change the permissions on your private key. In mac/linux:

```
chmod 400 [PATH TO YOUR PRIVATE KEY]
```
    
11. install R using:
```
> sudo yum install -y R
> sudo yum install libxml2-dev
```
from the EC2 command prompt.
    
12. The GPU compiler (nvcc) cannot use the latest version of the standard C compiler (gcc)
    To fix this:
```
> sudo rm /etc/alternatives/gcc
> sudo ln -s /usr/bin/gcc48 /etc/alternatives/gcc
```

13. run R as root using:
```
sudo R
```

14. From R install devtools, and install gpuideal:
```
> install.packages("devtools")
> devtools::install_github("JeffreyBLewis/gpuideal")
```

15. Quit `R` (`ctrl-D`) and run R as a regular user: `R`. Test your installation by running the examples above.
    
17. To copy your data to your EC2 instance from a mac/linux machine you can use:
```
    scp -i [PATH TO YOUR PRIVATE KEY] -C [PATH TO YOUR DATA] [USERNAME]@[IP ADDRESS]:~/[NAME FOR YOUR DATA]
```


