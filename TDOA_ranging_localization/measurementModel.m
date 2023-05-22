function [ h ] = measurementModel(parameters,UE,AP)

%% build the vector/matrix of observation
h = []; % 1 x numberOfAP - 1
for a = 1:parameters.numberOfAP
    if a ~= parameters.mainSTA
        distToMain = sqrt(sum([UE - AP(parameters.mainSTA,:)].^2,2));
        distToSTA = sqrt(sum([UE - AP(a,:)].^2,2));
        TDOA = distToSTA - distToMain;
        h = [h; TDOA];
    end
end