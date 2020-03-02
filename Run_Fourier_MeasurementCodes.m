function [ wave ] = ...
    Run_Fourier_MeasurementCodes( Measure_Dir,...
    periodlist,EventName,RayleighorLove,OutputDir )
% Makes measurements of all the surface waves in sac files
% in the directory that is specified. 
if RayleighorLove == 1
    wave = 'Rayleigh';   
elseif RayleighorLove == 0
    wave  = 'Love';
end

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

    % Get predicted group velocities for your surface wave here    
    [ tclosest,grpvel_pred,phvel_pred ] = ...
        Get_ATL2a_PhGrpVel( period,RayleighorLove )
    %

    RA = zeros(1,length(flist)); IA = zeros(1,length(flist));
    PhaseList = zeros(1,length(flist));

    for ii = 1:length(flist)

       100*ii/length(flist)
       currname = flist(ii).name; Zfname = [Measure_Dir currname];

       % Extract information about the wave
       s=readsac(Zfname);
       stla(ii)=s.STLA;
       stln(ii)=s.STLO;
       evla(ii)=s.EVLA;
       evln(ii)=s.EVLO;
       baz(ii)=s.BAZ;
    
       [evdist,AZ] = distance(s.STLA,s.STLO,s.EVLA,s.EVLO);

       [t,v1]=readsac(Zfname);
       
       %%%% Now filter and make the measurements
       % Filter the Wave first
       vf1=bandpassSeis(v1,1,lowfbound,highfbound);
       pred_tt = deg2km(evdist)./grpvel_pred;
       [ vf_windowed ] = Window_A_Waveform( t,vf1,1,tukeyratio,pred_tt,windowlen );                                         

       [ RealAmp,ImagAmp,PhaseOut ] = MeasurePhaseAmpWithFFt( t,vf_windowed,1e-8,period );
       RA(ii) = RealAmp; IA(ii) = ImagAmp; PhaseList(ii) = PhaseOut;
       distlist(ii) = evdist;

    end 
    
    [distsorted,sortdx] = sort(distlist);
    
    zz(:,1) = distsorted; zz(:,2) = RA(sortdx); zz(:,3) = IA(sortdx);
    zz(:,4) = sqrt(RA(sortdx).^2 + IA(sortdx).^2);
    zz(:,5) = PhaseList(sortdx); zz(:,6) = stln(sortdx); 
    zz(:,7) = stla(sortdx); 
    outfile = strcat(EventName,wave,'Measurements',num2str(period),'s');
    dlmwrite(outfile,zz,'delimiter','\t','precision','%.9f')
    movefile(outfile,OutputDir)
    
end

end

