% fitness_model2_withzero.m
% fitness pre model 2. radu s nulou (x = [a1,a2,b0,b1,d])
function J = fitness_model2_withzero(x, u, y)
    a1 = x(1); a2 = x(2); b0 = x(3); b1 = x(4); d = round(x(5));
    if d < 0
        J = 1e6; return;
    end
    yhat = simulate_model2(a1,a2,b0,b1,d,u);
    if any(isnan(yhat)) || ~isfinite(sum(yhat))
        J = 1e6; return;
    end
    e = y(:) - yhat(:);
    J = mean(e.^2);
end
