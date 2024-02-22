# SW_PhAmp

## Purpose.

This suite of functions allows one to measure surface-wave phase and amplitude from an arbitrary set of seismograms at dense arrays of stations. The seismograms are windowed in time by assuming a group arrival time corresponding to predictions from a 1D oceanic or continental Earth model. The window is a Tukey window. The phase and amplitude measurements are constructed by calculating (for phase) the complex angle from the fourier transform of the windowed waveform, or (for amplitude) simply taking the magnitude of the real and imaginary components.

## Installation.

Download the folder and ensure all the codes and functions within are in your path. After changing your directory so you are in the downloaded folder, you can run:
```Matlab
addpath(genpath(pwd))
```
The function that makes the measurements is:
```Matlab
[ wave ] =  Run_Fourier_MeasurementCodes( Measure_Dir,periodlist,EventName,RayleighorLove,OutputDir )
```
You need to specify the following inputs to run the code. 

(1) 'Measure_Dir' is the name of the folder that contains your seismograms as sac files. 

(2) 'periodlist' is a vector of periods at which you want to make your measurements, e.g. periodlist = [20 40 60 90 100]

(3) 'EventName' is a prefix for all your output files- this just is a string.

(4) 'RayleighorLove' is 1 or 0, corresponding to Rayleigh and Love waves respectively. This flag changes the expected file names of the seismograms and the group window used.

(5) 'OutputDir' is a string that contains a path to a directory where your output files are stored. 

The function ```Matlab Read_FFT_Measurements( fname,period ) ``` contains the format of the output files. 
An example of running the codes on synthetic data (provided in DemoFolder_SynthData) is shown in Demonstrate_Measurements.m. 

Contact Anant Hariharan with any questions: ahariharan@ucsb.edu

