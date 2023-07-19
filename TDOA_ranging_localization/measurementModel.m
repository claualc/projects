function [ h ] = measurementModel(parameters,UE,AP,TYPE)

%% compute the distance between UE and APs
distanceUEAP = sqrt( sum( [UE - AP].^2 , 2 ) ); 

%% build the vector/matrix of observation
h  = [];
for a = 1:parameters.numberOfAP
    if a~= parameters.mainSTA
        h = [h,distanceUEAP(a)-distanceUEAP(parameters.mainSTA)];
    end
end