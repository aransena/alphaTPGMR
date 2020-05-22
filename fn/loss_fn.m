function sum_error = loss_fn(s, test_set)
% L2 Loss
sum_error = 0;
for n=1:length(s)
    for i = 1:length(s(1).Data)        
             sum_error = sum_error + (s(n).Data(2,i)-test_set(n).Data(2,i)^2+(s(n).Data(3,i)-test_set(n).Data(3,i))^2);
    end
end
sum_error = sum_error/(length(s));
end