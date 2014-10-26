# README.md

These are user notes for the symmmetry.m script written by [Ken Hwang](ken.r.hwang@gmail.com) and available at this [GitHub repo](https://github.com/krh5058/Symmetry).

## Dependencies
- Matlab or Gnu Octave, 32 bit only because of dependencies on the [Psychophysics Toolbox](https://psychtoolbox.org/HomePage). Code was developed on a PC, with Matlab version 7.13.0.564 (R2011b).
- Psychophysics Toolbox](https://psychtoolbox.org/HomePage), PTB: 3.0.10 or greater
- Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) Client VM mixed mode
- Windows 7 or Mac OS X.
- For MRI scanner-triggered start, must have optical-USB connection to computer.

## Support files

- There are a set of image files in a directory called images/. These files are named with the following convention: mmmiii.PGM, where the mmm is in 101-134 and the iii is in 001...020. The mmm prefix indexes the wallpaper group these represent, and whether the images are phase scrambled| (118+) or not (101-117).
 
|prefix|group|phase|
|------|-----|-----|
|101| p1 | intact |
|102|p2  |intact |
|103|pm  |intact|
|104|pg  |intact|
|105|cm  |intact|
|106|pmm |intact|
|107|pmg |intact|
|108|pgg |intact|
|109|cmm |intact|
|110|p4  |intact|
|111|p4m |intact|
|112|p4g |intact|
|113|p3  |intact|
|114|p3m1|intact|
|115|p31m|intact|
|116|p6  |intact|
|117|p6m |intact|
|118|p1  |scrambled|
|119|p2  |scrambled|
|120|pm  |scrambled|
|121|pg  |scrambled|
|122|cm  |scrambled|
|123|pmm |scrambled|
|124|pmg |scrambled|
|125|pgg |scrambled|
|126|cmm |scrambled|
|127|p4  |scrambled|
|128|p4m |scrambled|
|129|p4g |scrambled|
|130|p3  |scrambled|
|131|p3m1|scrambled|
|132|p31m|scrambled|
|133|p6  |scrambled|
|134|p6m |scrambled|

- Here are some comments from Peter Kohler about how these were generated. 
    
    Rick,

    apologies for the delay. We now have a set of images that we are happy with. I consists of 20 exemplars of each of the 17 groups, with a corresponding phase-scrambled image for each exemplar, so 34x20 = 680 images. We will only be using 10 exemplars from each category, but you can obviously use all 20 if you want. I have uploaded all the images to a folder in the shared google drive folder, called stim_feb2014. The top-level of this folder contains the 680 images, as well as a subfolders called analysis, which contains some diagnostic plots we have created for each exemplar, and an image of the pattern at each step of image processing. Most importantly, this folder also contains a .mat file that contains all the images, at three different processing steps, stored in the variables symAveraged, symFiltered and symMasked. The latter is the final version that we use in the experiment. The .mat file also contains the variable Groups, which has the names of the 17 groups, in order. The first cell in this variable is P1, meaning that P1 images are named "101...", second is P2, named "102..." and so on.

    Let me know if you have any questions.

    Best,

    Peter

# Run-time instructions

1. Log on to projector PC in 7 Chandlee. User: SLEIC, PW: sleic2013
2. Open Matlab 2011b (in ...)
3. Confirm video settings
4. Check Nordic Neurolab grips connection
5. 
