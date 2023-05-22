function [ H ] = buildJacobianMatrixH(parameters,UE,AP)

%% compute the distance between UE and APs
distanceUEAP = sqrt( sum( [AP-UE].^2 , 2 ) ); 

%% build H
H = []; %parameters.numberOfAP x 2 
for a = 1:parameters.numberOfAP
    if a ~= parameters.mainSTA
        aj = (AP(parameters.mainSTA)-UE)./distanceUEAP(parameters.mainSTA);
        ai = (AP(a)-UE)./distanceUEAP(a);
        item = [aj(1)-ai(1) , aj(2)-ai(2)];
        H = [ H; item ];
    end
end

end

