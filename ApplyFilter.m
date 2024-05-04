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
