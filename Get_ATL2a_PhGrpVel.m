function [ Closest_Periodlist,GrpVellist,Phvellist ] = ...
    Get_ATL2a_PhGrpVel( Periodlist,RayleighorLove )
% For the oceanic model ATL2a (James et al., 2014)
%
% Loads in the group velocities for an oceanic Earth model
% and also phase velocities...
% If RayleighorLove is 1 then assumes Rayleigh,
% but if RayleighorLove is 0, then assumes Love.

if RayleighorLove == 1    
    TUCInfo = load('atl2a_Rayl_TUc_br0.dms');
elseif RayleighorLove == 0    
    TUCInfo = load('atl2a_Love_TUc_br0.dms');   
end

T = TUCInfo(:,1);
U = TUCInfo(:,2);
C = TUCInfo(:,3);

Closest_Periodlist =[];
GrpVellist = [];
Phvellist = [];


for i = 1:length(Periodlist) 
    
    [mindiff,closestidx] = min(abs(T-Periodlist(i)));
    Phvellist(i) = C(closestidx);
    GrpVellist(i) = U(closestidx);
    Closest_Periodlist(i) = T(closestidx);

end

end

