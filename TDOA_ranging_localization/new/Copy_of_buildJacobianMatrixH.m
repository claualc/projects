function [ H ] = Copy_of_buildJacobianMatrixH(parameters,UE,AP)
    %% compute the distance between UE and APs
    distanceUEAP = sqrt( sum( [UE - AP].^2 , 2 ) ); 
    
    %% evaluate direction cosine
    main = parameters.mainSTA;
    NA = parameters.numberOfAP;
    
    directionCosineXi = ( UE(1)-AP(:,1) ) ./ distanceUEAP;
    directionCosineYi = ( UE(2)-AP(:,2) ) ./ distanceUEAP;
    
    directionCosineMain = [directionCosineXi(main),directionCosineYi(main)];
    
    subDirectionCosineX = [directionCosineXi-directionCosineMain(1)];
    subDirectionCosineY = [directionCosineYi-directionCosineMain(2)];
    
    %% build H
    H = [];
    
    for a = 1:parameters.numberOfAP
        if a~= parameters.mainSTA
            H = [H; subDirectionCosineX(a) , subDirectionCosineY(a) ];
        end
    end
end