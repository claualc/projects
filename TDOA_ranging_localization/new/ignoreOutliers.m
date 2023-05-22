function [array] = ignoreOutliers(array)

    % Interpolate values ignoring outliers
    array(isnan(array)) = 0;
    max_v = .05;
    for i = 1:length(array)
        if length(array) >= i+1
            init = array(i);
            final = array(i+1);

            diff = (final-init);

            if abs(diff) > max_v
                if diff > 0
                    array(i+1) = init + max_v;
                else
                    array(i+1) = init - max_v;
                end
            end
            
        end
    end
end