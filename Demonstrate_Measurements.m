%% Quick Sanity Test of Measurements of Phase and Amplitude
%% on synthetic seismograms to convince me

clear; clc; close all;

%%%%%% Manually Input Parameters for your project below here
%%%%%%
% What folder are your seismograms in?
Measure_Dir = 'DemoFolder_SynthData/';
% What periods do you want measurements to be made at?
periodlist = [50 100]
% Name of the event, used in the filename of the output
EventName = '200709280135';
% Make measurements on Rayleigh (Vert-comp) or Love (T-comp) waves?
% 1 for Rayleigh, 0 for Love.
% Note that if 1, the code expects seismograms with *HZ in the filename
% and if 0, the code expects seismograms with *HT in the filename
RayleighorLove = 1; 
OutputDir = 'OutputMeasurements';
%%%%%% Now run the measurement codes! 

mkdir(OutputDir)
[ wave ] = ...
    Run_Fourier_MeasurementCodes( Measure_Dir,...
    periodlist,EventName,RayleighorLove,OutputDir )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Now read and plot the measurements 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
File_50s = ['OutputMeasurements/200709280135RayleighMeasurements50s'];
[ dist,tt,amp,stalon,stalat,evlon,evlat ] = Read_FFT_Measurements( File_50s,50 );

[ Closest_Periodlist,GrpVellist,Phvellist ] = ...
    Get_STW105_PhGrpVel( 50,1 );
tpred = deg2km(dist)./Phvellist(1);

% Eliminate these measurements because they're isolated stations and so
% unwrapping is hard to do...
tpred(find(dist > 110)) = [];  
stalat(find(dist > 110)) = [];
stalon(find(dist > 110)) = [];
tt(find(dist > 110)) = [];
amp(find(dist > 110)) = [];
dist(find(dist > 110)) = [];
%

p = polyfit(tt,deg2km(dist),1);
pint = polyfit(deg2km(dist),tt,1);
figure(1)
subplot(1,2,1)
scatter(dist,tt)
hold on
plot(dist,tpred+pint(2),'linewidth',2,'color','k')
xlabel('Epicentral Distance')
ylabel('Traveltime')
legend('Measured','Predicted Assuming STW105 Phase Velocities')
set(gca,'fontsize',18)
title('Measured Rayleigh Wave Traveltimes')
grid on; box on; 
subplot(1,2,2)
scatter(dist,amp,10,'filled')
hold on
xlabel('Epicentral Distance')
ylabel('Amplitude')
set(gca,'fontsize',18)
title('Measured Rayleigh Wave Amplitudes')
grid on; box on; 
set(gcf,'position',[19 241 1379 503])
figure(2)
scatter(stalon,stalat,50,amp,'filled')
xlabel('Latitude')
ylabel('Longitude')
barbar=colorbar;
ylabel(barbar,'Measured Amplitude')
set(gca,'fontsize',18)
title('Measured Rayleigh Wave Amplitudes')
