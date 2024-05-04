function [normalizedImage] = Normalize(image)
    % Normalize - Normalize the values of an input image
    % Subtract the minimum value to set the minimum to zero.
    normalizedImage = image - min(image(:));
    normalizedImage = normalizedImage / max(normalizedImage(:));
end
