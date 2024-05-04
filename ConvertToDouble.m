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
