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
