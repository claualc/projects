function [ H ] = buildJacobianMatrixH(parameters,UE,AP)
    %% build the jacobian matrix for TDOA meassurements

     %% compute the distance between UE and APs
    distanceUEAP = sqrt( sum( [UE - AP].^2 , 2 ) ); 
    
    %% evaluate direction cosine
    main = parameters.mainSTA;
    NA = parameters.numberOfAP;
    
    directionCosineXi = ( UE(1)-AP(:,1) ) ./ distanceUEAP;
    directionCosineYi = ( UE(2)-AP(:,2) ) ./ distanceUEAP;
    
    subDirectionCosineX = [directionCosineXi-directionCosineXi(main)];
    subDirectionCosineY = [directionCosineYi-directionCosineYi(main)];
    
    %% build H
    H = [];
    
    for a = 1:parameters.numberOfAP
        if a~= parameters.mainSTA
            H = [H; subDirectionCosineX(a) , subDirectionCosineY(a) ];
        end
    end
end