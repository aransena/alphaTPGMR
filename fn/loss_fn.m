function sum_error = loss_fn(s, test_set)
    sum_error = 0;
    for n=1:length(s)   
        for i = 1:size(s(1).Data, 2)
                  x = (squeeze(s(n).Data(2:end, i)-test_set(n).Data(2:end, i)));
                  W1 = eye(size(s(1).Data, 1) - 1) * norm(squeeze(test_set(n).Sigma(:, :, i)));
                  sum_error = sum_error + (x'*W1*x);
        end
    end
end