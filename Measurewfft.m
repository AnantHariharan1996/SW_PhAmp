%% Explores the Measurement of wave phase using a fourier transform
EventName = 'C201802251744A';
Measure_Dir = ['/Users/ahariharan/LoveWave_OvertoneInterference/TPW/3D_Synthetics/' evid '/'];
periodlist = [100];

modes = 0;

for iijjkk = 1:length(periodlist)
    period=periodlist(iijjkk);

    if RayleighorLove == 1
        flist = dir([Measure_Dir '*HZ.sac']);
    elseif RayleighorLove == 0
        flist = dir([Measure_Dir '*HT.sac']);
    end
    
    f = 1/period;
    lowfbound = 0.9*f; 
    highfbound =  1.1*f;
    windowlen = period*2;
    tukeyratio=0.5;
    
    
    
    %% Get predicted group velocities for your phase here
    
    [ tclosest,grpvel_pred,phvel_pred ] = ...
        Get_ATL2a_PhGrpVel( period,RayleighorLove )
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
%        [t,vE1]=readsac(Efname);       
%        [t,vN1]=readsac(Nfname);
%        [t,vZ1]=readsac(Zfname);
%        SEIS(:,1) = vE1;
%        SEIS(:,2) = vN1;
%        SEIS(:,3) = vZ1;
% %       [t,v1]=readsac(fname);
%        
%        % Rotate to different components % [ T, R, Z ]
%        [SEIS_Out, KEY] = rotateSeisENZtoTRZ( SEIS , s.BAZ );
%        Transverse = SEIS_Out(:,1);
%        Radial = SEIS_Out(:,2);
%        Vertical = SEIS_Out(:,3);
%       
%        
%        if Measure_Love
%            v1 = Transverse;
%        end
%        
%        if Measure_Rayleigh
%            v1 = Vertical;
%        end
       
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


    save([num2str(evid) '_RA' num2str(period) 's.mat'],'RA')
    save([num2str(evid) '_PhaseList' num2str(period) 's.mat'],'PhaseList')
    save([num2str(evid) '_IA' num2str(period) 's.mat'],'IA')
    save([num2str(evid) 'lonlist.mat'],'stln')
    save([num2str(evid) 'latlist.mat'],'stla')
end