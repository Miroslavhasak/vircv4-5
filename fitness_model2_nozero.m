% fitness_model2_nozero.m
% fitness pre model 2. radu bez nuly (x = [a1,a2,b0,d])
function J = fitness_model2_nozero(x, u, y)
    a1 = x(1); a2 = x(2); b0 = x(3); d = round(x(4));
    % jednoducha penalizacia pre stabilitu: ak polynomy su poza rozsahu
    if d < 0
        J = 1e6; return;
    end
    yhat = simulate_model2(a1,a2,b0,0,d,u);
    if any(isnan(yhat)) || ~isfinite(sum(yhat))
        J = 1e6; return;
    end
    e = y(:) - yhat(:);
    J = mean(e.^2);
end
