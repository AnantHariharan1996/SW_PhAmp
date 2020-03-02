%% Explores the Measurement of mineos synths using fourier analysis
clear
Measurement_ID = '205000000000';
Measure_Dir = ['/Users/ahariharan/Advanced_Rayleigh_Overtone_Int/Strike0_DipSlipvsVerticalFaulting/Strike0_VerticalDipDipSlipSynths/out_br0to1_2050Strike0_VertDip/'];
periodlist = [100];

Measured_Phase = 1; % Corresponds to Rayleigh. Setting this to 0 
% corresponds to Love.

for iijjkk = 1:length(periodlist)
    period=periodlist(iijjkk);
    
    if Measured_Phase == 1
        flist = dir([Measure_Dir '*Z.sac']);
    elseif Measured_Phase == 0
        flist = dir([Measure_Dir '*T.sac']);        
    end
    

    f = 1/period;
%     lowfbound = 1/300; %0.9*f; %Original- yields good results with 100s...
%     highfbound =  1/10; %1.1*f;
    lowfbound = 0.9*f; 
    highfbound =  1.1*f;
    windowlen = period*2;
    tukeyratio=0.5;
    
    
    
    %% Get predicted group velocities for your phase here
    
 [ Closest_Period,grpvel_pred,phvelpred ] = ...
    Get_ATL2a_PhGrpVel( period,Measured_Phase )   
    
    %%

    RA = zeros(1,length(flist));
    IA = zeros(1,length(flist));
    PhaseList = zeros(1,length(flist));

    for ii = 1:length(flist)

       100*ii/length(flist)
       currname = flist(ii).name;

       Zfname = [Measure_Dir currname];

       % Extract information about the wave
       s=readsac(Zfname);
       stla(ii)=s.STLA;
       stln(ii)=s.STLO;
       evla(ii)=s.EVLA;
       evln(ii)=s.EVLO;
       baz(ii)=s.BAZ;
       % Read in E, N, Z separately for this station and put into a SEIS
       % array
    
       [evdist,BAZ] = distance(s.STLA,s.STLO,s.EVLA,s.EVLO);

       [t,v1]=readsac(Zfname);
       
       
       %%%% Now filter and make the measurements
       % Filter the Wave first
       vf1=bandpassSeis(v1,1,lowfbound,highfbound);
       pred_tt = deg2km(evdist)./grpvel_pred;
       [ vf_windowed ] = Window_A_Waveform( t,vf1,1,tukeyratio,pred_tt,windowlen );                                         

       [ RealAmp,ImagAmp,PhaseOut ] = MeasurePhaseAmpWithFFt( t,vf_windowed,1e-8,period );
       RA(ii) = RealAmp;
       IA(ii) = ImagAmp;           
       PhaseList(ii) = PhaseOut;

    end                                                  

    figure()
    subplot(2,2,1)
    scatter(stln,stla,50,PhaseList,'filled')
    grid on
    box on
    xlabel('Longitude')
    ylabel('Latitude')
    title('Phase')
    colorbar

    subplot(2,2,2)
    scatter(stln,stla,50,RA,'filled')
    grid on
    box on
    xlabel('Longitude')
    ylabel('Latitude')
    title('Real Amplitude')
    colorbar

    subplot(2,2,3)
    scatter(stln,stla,50,IA,'filled')
    grid on
    box on
    xlabel('Longitude')
    ylabel('Latitude')
    title('Imaginary Amplitude')
    colorbar

    subplot(2,2,4)
    scatter(stln,stla,50,sqrt(IA.^2 + RA.^2),'filled')
    grid on
    box on
    xlabel('Longitude')
    ylabel('Latitude')
    title('Complete Amplitude')
    colorbar


    save([num2str(evid) 'Strike0_VertDip_B0to1_Rayleigh_RA' num2str(period) 's.mat'],'RA')
    save([num2str(evid) 'Strike0_VertDip_B0to1_Rayleigh_PhaseList' num2str(period) 's.mat'],'PhaseList')
    save([num2str(evid) 'Strike0_VertDip_B0to1_Rayleigh_IA' num2str(period) 's.mat'],'IA')
    save([num2str(evid) 'Strike0_VertDip_B0to1_Rayleigh_lonlist.mat'],'stln')
    save([num2str(evid) 'Strike0_VertDip_B0to1_Rayleigh_latlist.mat'],'stla')
end


%% Quick test of plotting by distance, since our tpw works in 1d

[alen,az] = distance(evla,evln,stla,stln);

figure()
scatter(alen,sqrt(IA.^2 + RA.^2))