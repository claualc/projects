function [ rho ] = generateTOAMeasurements(parameters,UEx,UEy)

    T   = parameters.simulationTime; %s
    NA  = parameters.numberOfAP;
    
    rho = zeros(T,NA-1);
    for time=1:T
        rho(time,:) = UEx(time,:);
    end
        
end