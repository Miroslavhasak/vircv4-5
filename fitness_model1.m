% fitness_model1.m
% fitness pre GA pre model 1. radu (x = [K,T,d])
function J = fitness_model1(x, u, y, Ts)
    K = x(1); T = x(2); d = round(x(3));
    if T <= 0 || K < 0 || d < 0
        J = 1e6; return;
    end
    yhat = simulate_model1(K,T,d,u,Ts);
    if any(isnan(yhat)) || ~isfinite(sum(yhat))
        J = 1e6; return;
    end
    e = y(:) - yhat(:);
    J = mean(e.^2);
end
