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
