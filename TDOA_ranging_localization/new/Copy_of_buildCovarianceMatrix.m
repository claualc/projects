function [R] = Copy_of_buildCovarianceMatrix( parameters  )
    % construct a diagonal matrix
    R = diag( repmat( parameters.sigmaTDOA.^2 , 1 , parameters.numberOfAP-1 ) );
end