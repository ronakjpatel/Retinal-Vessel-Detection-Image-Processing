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
