%Input Image
image= imread('G:\matlab_img_procesing\IP_Project\DataSet\training\images\37_training.tif');
mask= imread('G:\matlab_img_procesing\IP_Project\DataSet\training\mask\37_training_mask.gif');
double_depth_image = im2double(image);
gray_image= rgb2gray(double_depth_image);
smoothing = fspecial('average', [3 3]);
smoothed = imfilter(gray_image, smoothing);

%best params accroding to paper used for wide vessels detection
x=ExtractRetinalVessels(smoothed,1.5,9,22,mask,2.3);
%best params accroding to paper used for narrow vessels detection
y=ExtractRetinalVessels(smoothed,1,5,22,mask,2.3);

% Perform the logical OR operation to get the best of both
result_image = x | y;
figure;
imshow(result_image);
titleStr = "Image";
title(titleStr);


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

function [outputImage] = ConvertToDouble(inputImage)
    % ConvertToDouble - Convert the input image to double precision if it is not already.
    % Check if the input image is not already of double type.
    if isa(inputImage, 'double') ~= 1 
        % Convert the input image to double precision.
        outputImage = double(inputImage);
    else
        % If the input image is already of double type, keep it unchanged.
        outputImage = inputImage;
    end
end

function [matrix] = InitializeMatrix(rows, cols, depth)
    % Create a 3D matrix with specified dimensions and initialize with zeros.
    matrix = zeros(rows, cols, depth);
end




function [filteredImage] = ApplyFilter(image, sigma, yLength, theta, t)
    % ApplyFilter - Apply a specified filter to the input image
    if t == "match"
        filterKernel = CreateMatchedFilterKernel(sigma, yLength, theta);
    elseif t == "gaussian"
        filterKernel = CreateGaussianFilterKernel(sigma, yLength, theta);
    else
        error('Invalid filter type. Use "match" or "gaussian".');
    end
    % Apply convolution with the selected filter kernel.
    filteredImage = conv2(image, filterKernel, 'same');
end




function [resultImage] = ApplyThresholdAndMask(matchFilterResponse, threshold, mask)
    % Apply thresholding and masking to a given image.
    % Apply thresholding to create a binary image.
    thresholdedImage = matchFilterResponse >= threshold;
    % Apply the binary mask to the thresholded image.
    resultImage = thresholdedImage & mask;
    
end
function [threshold] = CalculateThreshold(matchFilterResponse, gaussDerivativeResponse, cValue)
    % CalculateThreshold - Calculate the threshold 
  
    % Apply average filtering to normalize the Gaussian derivative
    % response.
    %according to paper normalizedGaussDerivative=DM complement
    %in paper it is mentioned that the optimal parameter value for W=31*31
    %so here giving it.
    averageFilter = fspecial('average', 31);
    normalizedGaussDerivative = Normalize(imfilter(gaussDerivativeResponse, averageFilter));

    % Calculate the mean of the matched filter response.
    %according to paper meanMatchFilterResponse=MUh
    meanMatchFilterResponse = mean(matchFilterResponse(:));

    %according to paper thresholdConstant=Tc
    %Tc= c * MUh
    thresholdConstant = cValue * meanMatchFilterResponse;
    % Calculate the threshold .
    %according to paper threshold= T
    % T = (1+DM complement) * Tc
    threshold = (1 + normalizedGaussDerivative) * thresholdConstant;
end

function [customKernel] = CreateGaussianFilterKernel(customSigma, customYLength, angle)

    %setting up the dimesion of the kernal 
    % for safe side we are taking L^2 
    w = ceil(customYLength^2);
    r = 1;
    %making it odd dimensions if it is even
    if mod(w, 2) == 0
        w = w + 1;
    end
    %making w even just for hfl
    hfl_w = w-1;
    %setting up the y parameter of f(x,y) which is |y| <= L/2
    hf = hfl_w / 2;
    %lopoping through for filling up the kernal 
    for i = hf:-1:-hf
        c = 1;
        for j = -hf:hf
            three_s_val= 3 * ceil(customSigma);
            %this is the implementation rotation matrix.
            % this rotates given vector by counterclockwise angle theta in
            % a fixed coordinated system
            customXPrime = j * cos(angle) + i * sin(angle);
            customYPrime = i * cos(angle) - j * sin(angle);
            %getting the Absolute value of magnitude
            y=abs(customYPrime);
            x=abs(customXPrime);

            %disregarding the values lies outside the 3s accroding to the
            %paper for optimal performance.
            if x > three_s_val
                customKernel(r, c) = 0;
            elseif y > customYLength / 2
                customKernel(r, c) = 0;
            else
                %This is the equation of the first derivative of gaussian
                %function which we will use to fill up the matrix of the
                %kernal. 
                customKernel(r, c) = -exp(-.5 * (customXPrime / customSigma)^2) * customXPrime / (sqrt(2 * pi) * customSigma^3);
            end
            %increment the index along col
            c = c + 1;
        end
         %increment the index along row
        r = r + 1;
    end
   %finally returining the kernal 
    customKernel = customKernel;
end
function [customKernel] = CreateMatchedFilterKernel(customSigma, customYLength, angle)
 
    %setting up the dimesion of the kernal 
    % for safe side we are taking L^2     
    w = ceil(customYLength^2);
    r = 1;
    %making it odd dimensions of kernal if it is even
    if mod(w, 2) == 0
        w = w + 1;
    end
    %making w even just for hfl
    hfl_w = w-1;
    %setting up the y parameter of f(x,y) which is |y| <= L/2
    hf = hfl_w / 2;
    %lopoping through for filling up the kernal 
    %from positive to negative
    for i = hf:-1:-hf
        c = 1;
        for j = -hf:hf
            three_s_val= 3 * ceil(customSigma);
            %this is the implementation rotation matrix.
            % this rotates given vector by counterclockwise angle theta in
            % a fixed coordinated system 
            customYPrime = i * cos(angle) - j * sin(angle);
            customXPrime = j * cos(angle) + i * sin(angle);         
            %getting the Absolute value of magnitude
            y=abs(customYPrime);
            x=abs(customXPrime);
            %disregarding the values lies outside the 3s accroding to the
            %paper for optimal performance.
            if x > three_s_val
                customKernel(r, c) = 0;
            elseif y > customYLength / 2
                customKernel(r, c) = 0;
            else
                %This is the equation of the first derivative of gaussian
                %function which we will use to fill up the matrix of the
                %kernal.
                customKernel(r, c) = -exp(-.5 * (customXPrime / customSigma)^2) / (sqrt(2 * pi) * customSigma);
            end
            %increment the index along col
            c = c + 1;
        end
        %increment the index along row
        r = r + 1;
    end
    %returning the kernal
    customKernel = subtractM(customKernel,w);
end

function [normalizedImage] = Normalize(image)
    % Normalize - Normalize the values of an input image
    % Subtract the minimum value to set the minimum to zero.
    normalizedImage = image - min(image(:));
    normalizedImage = normalizedImage / max(normalizedImage(:));
end

function [finalmat] = subtractM(kernal, w)
    tot = sum(kernal(:));
    tot_num = sum(sum(kernal < 0));
    % Compute the m value.
    m = tot / tot_num;
    % Subtract the mean value from negative elements in the matrix.
    for i = 1:w
        for j = 1:w
            if kernal(i, j) < 0
                kernal(i, j) = kernal(i, j) - m;
            end
        end
    end

    % Output the resulting matrix.
    finalmat = kernal;
end
