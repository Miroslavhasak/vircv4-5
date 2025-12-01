% compute_metrics.m
% vypocet MSE, RMSE, MAE, MaxAbsErr, FitPercent
function metrics = compute_metrics(y, yhat)
    e = y(:) - yhat(:);
    MSE = mean(e.^2);
    RMSE = sqrt(MSE);
    MAE = mean(abs(e));
    MaxAbsErr = max(abs(e));
    if all(y==y(1))
        FitPercent = NaN;
    else
        FitPercent = 100 * (1 - norm(e)/norm(y - mean(y)));
    end
    metrics.MSE = MSE; metrics.RMSE = RMSE; metrics.MAE = MAE;
    metrics.MaxAbsErr = MaxAbsErr; metrics.FitPercent = FitPercent;
end
