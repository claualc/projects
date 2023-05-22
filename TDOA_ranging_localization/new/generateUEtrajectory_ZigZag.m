function [ UE ] = generateUEtrajectory_ZigZag(parameters)

T = parameters.simulationTime; %s
Ts = parameters.samplingTime ; %s
v = 2; %m/s

UE = zeros(T,2);
UE(1,:) = [25;0];
for time=2:T/4
    UE(time,:) = UE(time-1,:) + v.*Ts.*[1,1];    
end
for time=T/4+1:T/2
    UE(time,:) = UE(time-1,:) + v.*Ts.*[-1,1];    
end
for time=T/2+1:T-T/4
    UE(time,:) = UE(time-1,:) + v.*Ts.*[1,1];    
end
for time=T-T/4+1:T
    UE(time,:) = UE(time-1,:) + v.*Ts.*[-1,1];    
end

end