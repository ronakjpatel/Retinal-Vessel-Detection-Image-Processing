function [extractedVessels] = ExtractRetinalVessels(input_image, sigma_value, L, total_theta_counts, image_mask, c_value)

    processedImage = ConvertToDouble(input_image);
    % Get image size
    [img_rows, img_cols] = size(processedImage);

    % Initialize result matrices
    matchFilterResults = InitializeMatrix(img_rows, img_cols, total_theta_counts);
    gaussDerivativeResults = InitializeMatrix(img_rows, img_cols, total_theta_counts);

    % Apply filters in specified orientations
    for orientationIndex = 0:total_theta_counts-1
        orientationAngle = pi / total_theta_counts * orientationIndex;
        matchFilterResults(:,:,orientationIndex+1) = ApplyFilter(processedImage, sigma_value, L, orientationAngle, "match");
        gaussDerivativeResults(:,:,orientationIndex+1) = ApplyFilter(processedImage, sigma_value, L, orientationAngle, "gaussian");
    end

    % Compute maximum responses
    maxMatchFilterResponse = max(matchFilterResults, [], 3);
    maxGaussDerivativeResponse = max(gaussDerivativeResults, [], 3);

    % Calculate threshold
    threshold = CalculateThreshold(maxMatchFilterResponse, maxGaussDerivativeResponse, c_value);

    % Apply threshold and mask
    extractedVessels = ApplyThresholdAndMask(maxMatchFilterResponse, threshold, image_mask);
end
