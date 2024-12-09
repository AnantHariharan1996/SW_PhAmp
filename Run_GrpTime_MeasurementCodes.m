function [ wave ] = ...
    Run_GrpTime_MeasurementCodes( Measure_Dir,...
    periodlist,EventName,RayleighorLove,OutputDir )
% Makes measurements of all the surface waves in sac files
% in the directory that is specified. 

%%% HARDCODED PARAMS HERE
tukeyonoff = 1;
ContinentorOcean = 1; % 0 for continental, 1 for oceanic
%%%

if RayleighorLove == 1
    wave = 'Rayleigh';   
elseif RayleighorLove == 0
    wave  = 'Love';
end

for iijjkk = 1:length(periodlist)
    disp(['Completed Period ' num2str(periodlist(iijjkk)) 's'])
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
    if ContinentorOcean == 1
    [ tclosest,grpvel_pred,phvel_pred ] = ...
        Get_ATL2a_PhGrpVel( period,RayleighorLove );
    elseif ContinentorOcean == 0
    [ tclosest,grpvel_pred,phvel_pred ] = ...
        Get_STW105_PhGrpVel( period,RayleighorLove ) ;
    end
    %

    RA = zeros(1,length(flist)); IA = zeros(1,length(flist));
    PhaseList = zeros(1,length(flist));

    for ii = 1:length(flist)

      
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
       vf1=bandpassSeis(v1,t(2)-t(1),lowfbound,highfbound);
       pred_tt = deg2km(evdist)./grpvel_pred;
       [ vf_windowed ] = Window_A_Waveform( t,vf1,tukeyonoff,tukeyratio,pred_tt,windowlen );                                         
tol=1e-10;
       [ RealAmp,ImagAmp,PhaseOut ] = MeasurePhaseAmpWithFFt( t,vf_windowed,tol,period );
       RA(ii) = RealAmp; IA(ii) = ImagAmp; PhaseList(ii) = PhaseOut;
       distlist(ii) = evdist;

        %%%%%% Take the envelope of the waveform and extract the time
        %%%%%% corresponding to the peak of the envelope. 
        [YUPPER,YLOWER] = envelope(vf1);
        tnew = [min(t):0.1:max(t)];
        % Interpolate so we have subsample precision on the actual
        % measurement. 

        Vout = interp1(t,YUPPER,tnew);
        [maxmal,maxdx] = max(Vout);
        GrpTimelist(ii) = tnew(maxdx);
        

    end 
    
    [distsorted,sortdx] = sort(distlist);
    
    zz(:,1) = distsorted; zz(:,2) = RA(sortdx); zz(:,3) = IA(sortdx);
    zz(:,4) = sqrt(RA(sortdx).^2 + IA(sortdx).^2);
    zz(:,5) = GrpTimelist(sortdx); zz(:,6) = stln(sortdx); 
    zz(:,7) = stla(sortdx); zz(:,8) = evln(sortdx); 
    zz(:,9) = evla(sortdx);
    
    outfile = strcat(EventName,wave,'GrpMeasurements',num2str(period),'s');
    dlmwrite(outfile,zz,'delimiter','\t','precision','%.32f')
    movefile(outfile,OutputDir)
    
end

end

