function interpolatedArray = interpolateNaN(array)
    interpolatedArray = array;
    nanIndices = find(isnan(interpolatedArray)); % Find indices of NaN values
    
    for i = 1:length(nanIndices)
        index = nanIndices(i);
        
        % Find closest non-NaN values to the left and right
        leftIndex = find(~isnan(interpolatedArray(1:index-1)), 1, 'last');
        rightIndex = find(~isnan(interpolatedArray(index+1:end)), 1, 'first') + index;
        
        if ~isempty(leftIndex) && ~isempty(rightIndex)
            leftValue = interpolatedArray(leftIndex);
            rightValue = interpolatedArray(rightIndex);
            
            % Perform linear interpolation
            interpolatedValue = leftValue + (rightValue - leftValue) * (index - leftIndex) / (rightIndex - leftIndex);
            interpolatedArray(index) = interpolatedValue;
        end
    end
end