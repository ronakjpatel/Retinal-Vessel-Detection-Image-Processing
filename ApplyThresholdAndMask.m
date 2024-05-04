
function [resultImage] = ApplyThresholdAndMask(matchFilterResponse, threshold, mask)
    % Apply thresholding and masking to a given image.
    % Apply thresholding to create a binary image.
    thresholdedImage = matchFilterResponse >= threshold;
    % Apply the binary mask to the thresholded image.
    resultImage = thresholdedImage & mask;
    
end
